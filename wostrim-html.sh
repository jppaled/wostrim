#! /bin/bash

# current dir
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# streamer list
source "${DIR}/streamer_list.sh"

# tools to do calls on twitch api
source "${DIR}/apiTools.sh"

# database file containing the names and id of streams previously retrieved
source "${DIR}/database.sh"

# HTML start
HTML="<!DOCTYPE html>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <link rel='stylesheet' href='css/style.css'>
</head>
<body>
    <h1>Wostrim</h1>
    <div id='content'>   
"

# default streamer list from config.sh
STREAMER_LIST=("${LIST[@]}")

# if args was given, take it as streamer list
if [[ $# > 0 ]]; then
    STREAMER_LIST=("$@")
fi

# loop on every streamer given in args or in streamer_list.sh
for streamer in "${STREAMER_LIST[@]}"
do
    # get streamer info in database file
    existing_id="data_$streamer[0]"
    existing_name="data_$streamer[1]"
    
    # if streamer infos does not exist in the database
    if [ -z "${!existing_id}" ]; then
        # get streamer infos from twitch api
        USER=$(getTwitchUser $streamer)
    
        # if streamer found
        if [[ "$(echo $USER | jq -r '.data[].id' )" != 0 ]]; then 
            # store id and name
            USER_ID=$(echo $USER | jq -r '.data[].id')
            USER_NAME=$(echo $USER | jq -r '.data[].display_name')
            
            # save streamer infos in the database for next execution of script
            # this avoids redoing a call to the twitch api to get streamer infos
            array_name=data_${streamer}
            eval "$array_name=($USER_ID $USER_NAME)"
            declare -p $array_name >> "${DIR}/database.sh"
        else
            # streamer not found in twitch api
            continue
        fi
    else
        USER_ID="${!existing_id}"
        USER_NAME="${!existing_name}"
    fi
    
    # now we got streamer infos to get his stream infos
 
    # get stream infos from twitch api with his user id
    STREAM=$(getTwitchStream $USER_ID)
        
    # if stream is online
    if [[ "$(echo $STREAM | jq -r '.data[].type')" == "live" ]]; then 
        user_login=$(echo $STREAM | jq -r '.data[].user_login')

        # HTML stream infos
        HTML+="<div class='stream'>"
        HTML+="<a href='https://twitch.tv/$user_login'>"
        HTML+="<img class='thumbnail' src='https://static-cdn.jtvnw.net/previews-ttv/live_user_$user_login-328x204.jpg'/>"
        HTML+="<span class='username'>${USER_NAME^} </span><br/>"
        HTML+="<span class='game'>🕹️ $(echo $STREAM | jq -r '.data[].game_name')</span><br/>"
        HTML+="<span class='viewers'>👨‍💻️ $(echo $STREAM | jq -r '.data[].viewer_count')</span><br/>"
        HTML+="<span class='title'>$(echo $STREAM | jq -r '.data[].title')</span><br/>"
        HTML+="</a>"
        HTML+="</div>"
    fi
done

# HTML end
HTML+="</div></body>"

# write in the html file
echo -e "${HTML}" > "${DIR}/html/wostrim.html"

exit 0
