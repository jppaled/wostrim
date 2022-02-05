#! /bin/bash

# twitch client id key
source "${DIR}/config.sh"

function getTwitchUser() {
    local USER=$(curl \
    -s \
    --request GET  \
    --url "https://api.twitch.tv/kraken/users/?login=$1" \
    --header "Accept: $ACCEPT_VERSION" \
    --header "Client-ID: $CLIENT_ID")
    
    echo "$USER"
}

function getTwitchStream() {
    local STREAM=$(curl \
    -s \
    --request GET  \
    --url "https://api.twitch.tv/kraken/streams?limit=100&channel=$1" \
    --header "Accept: $ACCEPT_VERSION" \
    --header "Client-ID: $CLIENT_ID")
    
    echo "$STREAM"
}
