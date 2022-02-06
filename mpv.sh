#! /bin/bash

function openInMpv() {
    if $(mpv "https://www.twitch.tv/$1" --end=0.1 --vo=null --keep-open=no --msg-level=all=error | grep -q 'offline\|not exist'); then
        echo -e "$1 is not online or does not exist"
    else
        echo -e "The stream will start soon..."
        mpv --no-terminal "https://twitch.tv/$1" &
    fi
}
