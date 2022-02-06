#! /bin/bash

# function to open stream via multiple way
source "${DIR}/open.sh"

# On debian and ubuntu distributions notify-send will be used
function show_nofitication() {
    if which zenity > /dev/null; then
        aled=1
        
        while [ ${aled} -eq 1 ]; do
            zenity --notification --window-icon=$ICON --text="$1 start streaming !" --timeout 5

            aled=$?
            
            if [ $aled -eq 0 ]; then
                open $1
                break;
            fi
        done
    else 
        notify-send "$1 start streaming!" "$2" \
        -u normal -t 10000 -i $ICON
    fi
}
