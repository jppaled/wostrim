#! /bin/bash

function openInMpv() {
    # need to fix this, it does not works
    # https://github.com/mpv-player/mpv/issues/9834
    if $(mpv --msg-level=error=trace https://twitch.tv/$1 | grep -q 'offline\|not exist'); then
        echo "$1 is not online or does not exist"
    else
        mpv https://twitch.tv/$1
    fi
}

