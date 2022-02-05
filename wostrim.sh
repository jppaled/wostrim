#! /bin/bash

# current dir
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# streamer list
source "${DIR}/streamer_list.sh"

# some tools to get values in json file
source "${DIR}/jsonTools.sh"

# tools to do calls on twitch api
source "${DIR}/apiTools.sh"

# database file containing the names and id of streams previously retrieved
source "${DIR}/database.sh"

# colors
NOCOLOR='\033[0m'
LIGHTPURPLE='\033[1;35m'
MAGENTA='\e[1;45m'
CYAN='\e[1;46m'

INDEX=0

# default streamer list
STREAMER_LIST=("${LIST[@]}")

# if args take it as streamer list
if [[ $# > 0 ]]; then
    STREAMER_LIST=("$@")
fi

# loop on every streamer given in args or in config.sh
for streamer in "${STREAMER_LIST[@]}"
do
    INDEX=$(($INDEX + 1))

    # displays the streamer being parsed
    echo -e "$CYAN $INDEX $MAGENTA" ${streamer^} "$NOCOLOR"
    
    # get streamer infos from twitch api
    USER=$(getTwitchUser $streamer)
    
    # count number of streamer found
    USER_TOTAL=$(echo $USER | jsonValue _total )

    # if streamer is found
    if [[ "$USER_TOTAL" != 0 ]]; then
        # get his user id
        USER_ID=$(echo $USER | jsonValue _id)
        
        # get stream infos from twitch api with his user id
        STREAM=$(getTwitchStream $USER_ID)
        
        # if streamer is on live
        if [[ "$(echo $STREAM | jsonValue stream_type)" == "live" ]]; then 
            IS_ONE_STREAM_LIVE=true

            # display stream infos
            echo "game: "$(echo $STREAM | jsonValue game 1)
            echo "viewers: "$(echo $STREAM | jsonValue viewers)
            echo "title:" $(echo $STREAM | jsonValue status)
            echo $(echo $STREAM | getJsonValue url)
        else
            echo "No stream"
        fi
    else
        echo "Streamer not found"
    fi
    echo "----------------------------------------"
done

if [ $IS_ONE_STREAM_LIVE ]; then
    if which mpv > /dev/null; then
        echo "Which stream do you want to see ?"
        echo -e "- enter $MAGENTA streamer name $NOCOLOR or $CYAN number $NOCOLOR to start the stream"
        echo "- q to exit"

        read

        streamerArg=${REPLY}

        if [[ $streamerArg =~ ^[0-9]+$ ]]; then
            streamerArg=${!streamerArg}
        elif [[ $streamerArg == "q" ]]; then
            exit 0
        fi

        if $(mpv --realy-quiet https://twitch.tv/$streamerArg | grep -q 'offline\|not exist'); then
            echo "Not online or not exist"
        else
            mpv https://twitch.tv/$streamerArg
        fi
    else
        echo "CTRL + LEFT CLIC on twitch url to open the stream"
        exit 0
    fi
fi

exit 0
