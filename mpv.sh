#! /bin/bash

function openInMpv() {
    if $(mpv -msg-level https://twitch.tv/$1 | grep -q 'offline\|not exist'); then
        echo "$1 is not online or does not exist"
    else
        mpv https://twitch.tv/$1
    fi
}

