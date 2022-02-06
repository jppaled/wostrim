#! /bin/bash

function openInMpv() {
    if $(youtube-dl -sq "https://twitch.tv/$1" | grep -q 'offline\|not exist'); then
        echo -e "$1 is not online or does not exist"
    else
        echo -e "The stream will start soon..."
        mpv --no-terminal "https://twitch.tv/$1" &
    fi
}
