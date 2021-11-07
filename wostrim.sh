#! /bin/bash

source config.sh

NOCOLOR='\033[0m'
LIGHTPURPLE='\033[1;35m'
MAGENTA='\e[1;45m'
CYAN='\e[1;46m'

INDEX=0

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

    echo -e "$CYAN $INDEX $MAGENTA" ${CHANNEL^} "$NOCOLOR"

    if [[ "$TYPE" == "live" ]]
    then 
        GAME=$(echo $STREAM | jsonValue game 1)
        VIEWERS=$(echo $STREAM | jsonValue viewers)
        
        TITLE=$(echo $STREAM | jsonValue status)
        URL=$(echo $STREAM | getJsonValue url)

        echo "game: "$GAME
        echo "viewers: "$VIEWERS
        #echo $IS_LIVE
        echo "title:" $TITLE
        echo $URL
    else
        echo "No stream"
    fi

    echo "----------------------------------------"
}

for streamer in "$@"
do
    INDEX=$(($INDEX + 1))
    CHANNEL=$streamer
    getUser $streamer
done

if which mpv > /dev/null;
then
    echo "Which stream do you want to see ?"
    echo -e "- enter $MAGENTA streamer name $NOCOLOR or $CYAN number $NOCOLOR to start the stream"
    echo "- q to exit"

    read

    streamerArg=${REPLY}

    if [[ $streamerArg == [0-9] ]]
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