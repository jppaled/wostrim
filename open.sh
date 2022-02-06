#! /bin/bash

# open stream with mpv
source "${DIR}/mpv.sh"

function open() {
    if which mpv > /dev/null; then
        openInMpv $1
    else # open in the browser
        xdg-open "https://twitch.tv/$1"
    fi
}

