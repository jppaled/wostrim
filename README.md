# wostrim
bash script to see if your twitch streamer is online and get some infos like game name, number of viewers, stream url...

## config
you need to enter a twitch **client-id** key in the `config.sh` file

## your fav streamers

you can write channel's name of your fav streamers in the `streamer_list.sh` file

channel's name is the name after `https://twitch.tv/` in the url

like https://twitch.tv/zerator -> `zerator` is the name of the channel

in the config.sh you write your fav channel's name like this:

`LIST=(zerator laink ...)`


## run
```
./wostrim.sh zerator laink
```
or if you register some channel's name in the `streamer_list.sh` file
```
./wostrim.sh
```

## output
```
1 Zerator
game: Riders Republic
viewers: 6930
title: LE RETOUR DE RIDERS REPUBLIC
https://www.twitch.tv/zerator
----------------------------------------
2 Laink
game: Rocket League
viewers: 6121
title: Laink - ULTRA FOCUS
https://www.twitch.tv/laink
----------------------------------------
```

if you have `mpv`, it will start the stream automatically: 
```
Which stream do you want to see ?
- enter streamer name or number to start the stream
- q to exit

$ laink
```
if you don't have `mpv`:
```
CTRL + LEFT CLIC on twitch url to open the stream
```

## Database
there is a `database.sh` file which contains the `id` and the `name` of the streamer.

this file is filled after a call on the twitch api when the streamer is found.

this avoids having to call the twitch api again to retrieve this information 

## Genmon
I created a wostrim script for genmon that display number of online streamer

it works the same way as the `wostrim.sh` script

you can put the channel's name as an argument, or put them in the `streamer_list.sh` file

```
./wostrim-genmon.sh
```

add a generic monitor in your xfce pannel and add the path of the `wostrim-genmon.sh` script

if you hover over the twitch icon, it displays the list of online streamers, and their infos

## why I did this ?
I didn't want to have a twitch account, but to be able to know which of my streamers on twitch was on live

# todo
- ~~argument to lunch stream with mpv~~
- create desktop notification
- ~~multiple streamer name in argument~~
- explain how to get a client-id key
- make it works with twitch api token
