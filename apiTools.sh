#! /bin/bash

# twitch client id key
source "${DIR}/config.sh"

# randomize client-id used to avoid using the same id
#CLIENT_ID=${CLIENT_IDS[$[$RANDOM % ${#CLIENT_IDS[@]}]]}

function getTwitchUser() {
    local USER=$(curl \
    -s \
    --request GET  \
    --url "https://api.twitch.tv/helix/users?login=$1" \
    --header "Accept: $ACCEPT_VERSION" \
    --header "Client-ID: $CLIENT_ID" \
    --header "Authorization: Bearer ${TOKEN}")
    
    echo "$USER"
}

function getTwitchStream() {
    local STREAM=$(curl \
    -s \
    --request GET  \
    --url "https://api.twitch.tv/helix/streams?user_id=$1" \
    --header "Accept: $ACCEPT_VERSION" \
    --header "Client-ID: $CLIENT_ID" \
    --header "Authorization: Bearer ${TOKEN}")
    
    echo "$STREAM"
}
