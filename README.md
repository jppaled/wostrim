# wostrim
bash script to see if your twitch streamer is online and get some infos like game name, stream url...

# config
you need to enter a twitch **client-id** key in the `config.sh` file

# run
```
./wostrim.sh zerator laink
```
# output
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
- enter  streamer name  or  number  to start the stream
- q to exit

$ laink
```
if you don't have `mpv`:
```
CTRL + LEFT CLIC on twitch url to open the stream
```

# todo
- ~~argument to lunch stream with mpv~~
- create desktop notification
- ~~multiple streamer name in argument~~
- explain how to get a client-id key
- make it works with twitch api token
