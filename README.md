# Wostrim
bash script to see if your twitch streamer is online and get some infos like game name, number of viewers, stream url...

## Run
```
./wostrim.sh zerator laink
```
or if you register some channel's name in the `streamer_list.sh` file
```
./wostrim.sh
```

## Output
![wostrim-exemple](https://user-images.githubusercontent.com/22444128/152661561-29439b06-7bfa-4377-b561-cda2f8a7905f.png)

## Your fav streamers

you can write channel's name of your fav streamers in the `streamer_list.sh` file

channel's name is the name after `https://twitch.tv/` in the url

like https://twitch.tv/zerator -> `zerator` is the name of the channel

in the steamer_list.sh you write your fav channel's name like this:

`LIST=(zerator laink ...)`

## If you have `mpv` 
it will automatically start the stream with it

## If you don't have `mpv`:
It will start the stream in your browser

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

the icon will appear with the number of online streamer ![genmon](https://user-images.githubusercontent.com/22444128/152661294-9bb29c09-9c40-44d9-9be9-734dfd44f864.png)


if you hover over the twitch icon, it displays the list of online streamers, and their infos

![panel](https://user-images.githubusercontent.com/22444128/152661226-51ab2a53-c616-4fdb-9923-bdf2af325d1d.png)


## Why I did this ?
I didn't want to have a twitch account, but to be able to know which of my streamers on twitch was on live

# Todo
- ~~argument to lunch stream with mpv~~
- create desktop notification
- ~~multiple streamer name in argument~~
- explain how to get a client-id key
- make it works with twitch api token
