#! /bin/bash

# current dir
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# streamer list
source "${DIR}/streamer_list.sh"

# some tools to get values in json file
source "${DIR}/jsonTools.sh"

# tools to do calls on twitch api
source "${DIR}/apiTools.sh"

# open stream with mpv
source "${DIR}/mpv.sh"

# database file containing the names and id of streams previously retrieved
source "${DIR}/database.sh"

# colors
readonly NOCOLOR='\033[0m'
readonly LIGHTPURPLE='\033[1;35m'
readonly MAGENTA='\e[1;45m'
readonly CYAN='\e[1;46m'

INDEX=0
NB_STREAM_LIVE=0

# default streamer list
STREAMER_LIST=("${LIST[@]}")

# if args take it as streamer list
if [[ $# > 0 ]]; then
    STREAMER_LIST=("$@")
fi

# loop on every streamer given in args or in streamer_list.sh
for streamer in "${STREAMER_LIST[@]}"
do
    INDEX=$(($INDEX + 1))

    # displays the streamer being parsed
    echo -e "$CYAN $INDEX $MAGENTA" ${streamer^} "$NOCOLOR"
    
    # get streamer info in database file
    existing_id="data_$streamer[0]"
    existing_name="data_$streamer[1]"
    
    # if streamer infos does not exist in the database
    if [ -z "${!existing_id}" ]; then
        # get streamer infos from twitch api
        USER=$(getTwitchUser $streamer)

        # if streamer is found
        if [[ "$(echo $USER | jsonValue _total )" != 0 ]]; then
            # get his user id
            USER_ID=$(echo $USER | jsonValue _id)
            USER_NAME=$(echo $USER | jsonValue display_name)
            
            # save streamer infos in the database for next execution of script
            # this avoids redoing a call to the twitch api to get streamer infos
            array_name=data_${streamer}
            eval "$array_name=($USER_ID $USER_NAME)"
            declare -p $array_name >> database.sh
        else
            # streamer not found in twitch api
            echo "Streamer not found"
            continue
        fi
    else
        USER_ID="${!existing_id}"
        USER_NAME="${!existing_name}"
    fi
    
    # get stream infos from twitch api with his user id
    STREAM=$(getTwitchStream $USER_ID)
    
    # if streamer is on live
    if [[ "$(echo $STREAM | jsonValue stream_type)" == "live" ]]; then 
        NB_STREAM_LIVE=$(($NB_STREAM_LIVE + 1))

        # display stream infos
        echo "game: "$(echo $STREAM | jsonValue game 1)
        echo "viewers: "$(echo $STREAM | jsonValue viewers)
        echo "title:" $(echo $STREAM | jsonValue status)
        echo $(echo $STREAM | getJsonValue url)
    else
        echo "No stream"
    fi
 
    echo "----------------------------------------"
done

# if there is at least 1 stream on live choose to start one of the streams
if [ $NB_STREAM_LIVE -gt 0 ]; then
    if which mpv > /dev/null; then
        # if there is more than 1 stream on live
        if [ $NB_STREAM_LIVE -gt 1 ]; then
            echo "Which stream do you want to see ?"
            echo -e "- enter $MAGENTA streamer name $NOCOLOR or $CYAN number $NOCOLOR to start the stream"
            echo "- q to exit"
            
            read choice
            
             # if choice is a number
            if [[ $choice =~ ^[0-9]+$ ]]; then
                # i don't know how it works, it gives me the name of the streamer pliz help me
                choice=${!choice}
            elif [[ $choice == "q" ]]; then
                # quit
                exit 0
            fi
        else # so there is only one stream on live
            echo -e "Do you want to see $MAGENTA ${streamer^} $NOCOLOR stream ?"
            echo "- y to open the stream with mpv"
            echo "- q or n to exit"
            
            read choice
        
            if [[ $choice == "y" ]]; then
                choice=${streamer}
            elif [[ $choice == "q" || $choice == "n" ]]; then
                # quit
                exit 0
            else
                echo "I didn't understand 🤷, you can only choose y, q or n"
                exit 1
            fi
        fi
        
        openInMpv $choice
    else
        echo "CTRL + LEFT CLIC on twitch url to open the stream"
    fi
fi

exit 0
