#! /bin/bash

# current dir
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# streamer list
source "${DIR}/streamer_list.sh"

# some tools to get values in json file
source "${DIR}/jsonTools.sh"

# tools to do calls on twitch api
source "${DIR}/apiTools.sh"

# notification tool
source "${DIR}/notification.sh"

# database file containing the names and id of streams previously retrieved
source "${DIR}/database.sh"

# list of actual online stream
source "${DIR}/online.sh"

# twitch icon
readonly ICON="${DIR}/icon.png"

# color for streamer name
readonly MAGENTA="#ff79c6"

# default number of online streamers
STREAM_COUNT=0

# Genmon tooltip XML start
XTOOL="<tool>"

# default streamer list from config.sh
STREAMER_LIST=("${LIST[@]}")

# if args was given, take it as streamer list
if [[ $# > 0 ]]; then
    STREAMER_LIST=("$@")
fi

# loop on every streamer given in args or in streamer_list.sh
for streamer in "${STREAMER_LIST[@]}"
do
    # get streamer info in database file
    existing_id="data_$streamer[0]"
    existing_name="data_$streamer[1]"
    
    # if streamer infos does not exist in the database
    if [ -z "${!existing_id}" ]; then
        # get streamer infos from twitch api
        USER=$(getTwitchUser $streamer)
        
        # if streamer found
        if [[ "$(echo $USER | jsonValue _total )" != 0 ]]; then 
            # store id and name
            USER_ID=$(echo $USER | jsonValue _id)
            USER_NAME=$(echo $USER | jsonValue display_name)
            
            # save streamer infos in the database for next execution of script
            # this avoids redoing a call to the twitch api to get streamer infos
            array_name=data_${streamer}
            eval "$array_name=($USER_ID $USER_NAME)"
            declare -p $array_name >> "${DIR}/database.sh"
        else
            # streamer not found in twitch api
            continue
        fi
    else
        USER_ID="${!existing_id}"
        USER_NAME="${!existing_name}"
    fi
    
    # now we got streamer infos to get his stream infos
 
    # get stream infos from twitch api with his user id
    STREAM=$(getTwitchStream $USER_ID)

    # search if this stream was already notified
    in=1 # false
    for element in "${online_streamers[@]}"; do
        if [[ $element == "$streamer" ]]; then
            # stream already notified
            in=0 # true
            break
        fi
    done
        
    # if stream is online
    if [[ "$(echo $STREAM | jsonValue stream_type)" == "live" ]]; then 
        # increments the number of online streamers
        STREAM_COUNT=$((STREAM_COUNT + 1))
        
        # stream was not notified
        if [ $in -eq 1 ];then
            # update online streamer list
            online_streamers+=($streamer)
            
            # send notification
            show_nofitication $streamer "$(echo $STREAM | jsonValue game 1)" &
        fi
        
        # Genmon tooltip XML stream infos
        XTOOL+="<span fgcolor='${MAGENTA}'>${USER_NAME^}</span>\n"
        XTOOL+="<span>game: $(echo $STREAM | jsonValue game 1)</span>\n"
        XTOOL+="<span>viewers: $(echo $STREAM | jsonValue viewers)</span>\n"
        XTOOL+="<span>title: $(echo $STREAM | jsonValue status)</span>\n"
        XTOOL+="<span>----------------------------------------</span>\n"
    else   
        # streamer is no longer online 
        if [ $in -eq 0 ];then
            delete+=($streamer)
        fi
    fi
done

# remove stream that are no longer online in the online list
for target in "${delete[@]}"; do
    for i in "${!online_streamers[@]}"; do
        # remove
        if [[ ${online_streamers[i]} = "$target" ]]; then
            unset online_streamers[$i]
        fi
    done
done

# update actual online streamer list
declare -p online_streamers > "${DIR}/online.sh"

# Genmon tooltip XML end
XTOOL+="</tool>"

# Genmon panel XML
XPAN="<img>${ICON}</img>"
XPAN+="<txt>"
XPAN+=" ${STREAM_COUNT}"
XPAN+="</txt>"

# Echo the panel
echo "${XPAN}"

# Echo the tooltip
echo -e "${XTOOL}"

exit 0
