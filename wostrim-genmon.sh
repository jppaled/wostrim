#! /bin/bash

readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${DIR}/config.sh"
source "${DIR}/jsonTools.sh"

MAGENTA="#ff79c6"
STREAM_COUNT=0

# Genmon tooltip XML start
XTOOL="<tool>"

# default streamer list from config.sh
STREAMER_LIST=("${LIST[@]}")

# if args take it as streamer list
if [[ $# > 0 ]]; then
    STREAMER_LIST=("$@")
fi

for streamer in "${STREAMER_LIST[@]}"
do
    CHANNEL=$streamer
    
    # search streamer with name given
    USER=$(curl \
    -s \
    --request GET  \
    --url "https://api.twitch.tv/kraken/users/?login=$CHANNEL" \
    --header "Accept: $ACCEPT_VERSION" \
    --header "Client-ID: $CLIENT_ID")

    # if user found
    if [[ "$(echo $USER | jsonValue _total )" != 0 ]]; then 
        USER_ID=$(echo $USER | jsonValue _id)
        USER_NAME=$(echo $USER | jsonValue display_name)

        # get stream infos
        STREAM=$(curl \
        -s \
        --request GET  \
        --url "https://api.twitch.tv/kraken/streams?limit=100&channel=$USER_ID" \
        --header "Accept: $ACCEPT_VERSION" \
        --header "Client-ID: $CLIENT_ID")

        # if stream is online
        if [[ "$(echo $STREAM | jsonValue stream_type)" == "live" ]]; then 
            STREAM_COUNT=$((STREAM_COUNT + 1))
            
            # Genmon tooltip XML stream infos
            XTOOL+="<span fgcolor='${MAGENTA}'>${CHANNEL^}</span>\n"
            XTOOL+="<span>game: $(echo $STREAM | jsonValue game 1)</span>\n"
            XTOOL+="<span>viewers: $(echo $STREAM | jsonValue viewers)</span>\n"
            XTOOL+="<span>title: $(echo $STREAM | jsonValue status)</span>\n"
            XTOOL+="<span>----------------------------------------</span>\n"
        fi
    fi
done

# Genmon tooltip XML end
XTOOL+="</tool>"

# ******************************************************************************
# Genmon panel XML
XPAN="<txt>"
XPAN+="${STREAM_COUNT}"
XPAN+="</txt>"

# Echo the panel
echo "${XPAN}"

# Echo the tooltip
echo -e "${XTOOL}"
