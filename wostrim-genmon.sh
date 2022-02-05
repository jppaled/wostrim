#! /bin/bash

# current dir
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# streamer list
source "${DIR}/config.sh"

# some tools to get values in json file
source "${DIR}/jsonTools.sh"

# database file
source "${DIR}/data.sh"

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

# loop on every streamer given in args of in config.sh
for streamer in "${STREAMER_LIST[@]}"
do
    # get streamer info in database file
    existing_id="data_$streamer[0]"
    existing_name="data_$streamer[1]"
 
    USER_ID="${!existing_id}"
    USER_NAME="${!existing_name}"
    
#    echo "${!existing_id}"
#    echo "${!existing_name}"
    
    # if streamer infos does not exist in the database
    if [ -z "${!existing_id}" ]; then
        # search streamer with name given in the twitch api
        USER=$(curl \
        -s \
        --request GET  \
        --url "https://api.twitch.tv/kraken/users/?login=$streamer" \
        --header "Accept: $ACCEPT_VERSION" \
        --header "Client-ID: $CLIENT_ID")
        
        # if streamer found
        if [[ "$(echo $USER | jsonValue _total )" != 0 ]]; then 
            # store id and name
            USER_ID=$(echo $USER | jsonValue _id)
            USER_NAME=$(echo $USER | jsonValue display_name)
            
            # save streamer infos in the database for next execution of script
            # this avoids redoing a call to the twitch api to get streamer infos
            array_name=data_${streamer}
            eval "$array_name=($USER_ID $USER_NAME)"
            declare -p $array_name >> data.sh
        else
            # streamer not found in twitch api
            continue
        fi
    fi
    
    # now we got streamer infos to get his stream infos
 
    # get stream infos in the twitch api
    STREAM=$(curl \
    -s \
    --request GET  \
    --url "https://api.twitch.tv/kraken/streams?limit=100&channel=$USER_ID" \
    --header "Accept: $ACCEPT_VERSION" \
    --header "Client-ID: $CLIENT_ID")

    # if stream is online
    if [[ "$(echo $STREAM | jsonValue stream_type)" == "live" ]]; then 
        # increments the number of online streamers
        STREAM_COUNT=$((STREAM_COUNT + 1))
        
        # Genmon tooltip XML stream infos
        XTOOL+="<span fgcolor='${MAGENTA}'>${USER_NAME^}</span>\n"
        XTOOL+="<span>game: $(echo $STREAM | jsonValue game 1)</span>\n"
        XTOOL+="<span>viewers: $(echo $STREAM | jsonValue viewers)</span>\n"
        XTOOL+="<span>title: $(echo $STREAM | jsonValue status)</span>\n"
        XTOOL+="<span>----------------------------------------</span>\n"
    fi
done

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
