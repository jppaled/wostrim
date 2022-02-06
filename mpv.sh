#! /bin/bash

function openInMpv() {
    if $(mpv https://www.twitch.tv/$1 --end=0.1 --vo=null --keep-open=no | grep -q 'offline\|not exist'); then
        echo "$1 is not online or does not exist"
    else
        mpv --no-terminal https://twitch.tv/$1 &
    fi
}

