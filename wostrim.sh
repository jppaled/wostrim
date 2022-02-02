#! /bin/bash

readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${DIR}/config.sh"
source "${DIR}/jsonTools.sh"

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

    if [[ "$(echo $STREAM | jsonValue stream_type)" == "live" ]]
    then 
        IS_ONE_STREAM_LIVE=true
        STREAM_COUNT=$((STREAM_COUNT + 1))

        echo "game: "$(echo $STREAM | jsonValue game 1)
        echo "viewers: "$(echo $STREAM | jsonValue viewers)
        echo "title:" $(echo $STREAM | jsonValue status)
        echo $(echo $STREAM | getJsonValue url)
    else
        echo "No stream"
    fi
}

# ******************************************************************************
# main function
for streamer in "${STREAMER_LIST[@]}"
do
    INDEX=$(($INDEX + 1))
    CHANNEL=$streamer

    echo -e "$CYAN $INDEX $MAGENTA" ${CHANNEL^} "$NOCOLOR"
    getUser $streamer
    echo "----------------------------------------"
done

if [ $IS_ONE_STREAM_LIVE ]
then
    if which mpv > /dev/null
    then
        echo "Which stream do you want to see ?"
        echo -e "- enter $MAGENTA streamer name $NOCOLOR or $CYAN number $NOCOLOR to start the stream"
        echo "- q to exit"

        read

        streamerArg=${REPLY}

        if [[ $streamerArg =~ ^[0-9]+$ ]]
        then
            streamerArg=${!streamerArg}
        elif [[ $streamerArg == "q" ]]
        then
            exit 0
        fi

        if $(mpv --realy-quiet https://twitch.tv/$streamerArg | grep -q 'offline\|not exist');
        then
            echo "Not online or not exist"
        else
            mpv https://twitch.tv/$streamerArg
        fi
    else
        echo "CTRL + LEFT CLIC on twitch url to open the stream"
    fi
fi
# ******************************************************************************
