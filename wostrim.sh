#! /bin/bash

source config.sh

CHANNEL=$1

function jsonValue() {
    KEY=$1
    num=$2
    awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}

function getJsonValue() {
    grep -o '"'$1'":"[^"]*' | cut -d'"' -f4
}

function getUser() {
    USER=$(curl \
    -s \
    --request GET  \
    --url "https://api.twitch.tv/kraken/users/?login=$CHANNEL" \
    --header "Accept: $ACCEPT_VERSION" \
    --header "Client-ID: $CLIENT_ID")

    USER_TOTAL=$(echo $USER | jsonValue _total )

    if [[ "$USER_TOTAL" != 0 ]]
    then 
        getStream
    else
        echo "Streamer not found"
    fi

}

function getStream() {
    USER_ID=$(echo $USER | jsonValue _id)
    USER_NAME=$(echo $USER | jsonValue display_name)

    STREAM=$(curl \
    -s \
    --request GET  \
    --url "https://api.twitch.tv/kraken/streams?limit=100&channel=$USER_ID" \
    --header "Accept: $ACCEPT_VERSION" \
    --header "Client-ID: $CLIENT_ID")

    TYPE=$(echo $STREAM | jsonValue stream_type)
    #IS_LIVE=$(echo $([[ "$TYPE" == "live" ]] && echo true || echo false))

    if [[ "$TYPE" == "live" ]]
    then 
        GAME=$(echo $STREAM | jsonValue game 1)
        VIEWERS=$(echo $STREAM | jsonValue viewers)
        
        TITLE=$(echo $STREAM | jsonValue status)
        URL=$(echo $STREAM | getJsonValue url)

        echo $GAME
        echo $VIEWERS
        echo $IS_LIVE
        echo $TITLE
        echo $URL
    else
        echo "No stream"
    fi
}


getUser $CHANNEL
