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

in the `streamer_list.sh` you write your fav channel's name like this:

`LIST=(zerator laink ...)`

## If you have `mpv` 
it will automatically start the stream with it

## If you don't have `mpv`:
It will start the stream in your browser

## Database
there is a `database.sh` file which contains the `id` and the `name` of the streamer.

this file is filled after a call on the twitch api when the streamer is found.

this avoids having to call the twitch api again to retrieve this information 

```
declare -a data_zerator=([0]="41719107" [1]="ZeratoR")
declare -a data_laink=([0]="89872865" [1]="Laink")
```

## Genmon
I created a wostrim script for genmon that display number of online streamer

it works the same way as the `wostrim.sh` script

you can put the channel's name as an argument, or put them in the `streamer_list.sh` file

- First you have to install `xfce4-genmon-plugin` package if it is not on your system
- Add the monitor to the panel
    - Right click on the panel
    - Select _Panel -> Add new items_
    - Add _Generic Monitor_ plugin
- Set up the generic monitor to use with wostrim
    - Right click on the newly added generic monitor -> _Properties_
    - Command: `/path/to/wostrim-genmon.sh`
    - Uncheck the checkbox of _Label_
    - Set _Period_ to `300` seconds (5 minutes)

the icon will appear with the number of online streamer ![genmon](https://user-images.githubusercontent.com/22444128/152661294-9bb29c09-9c40-44d9-9be9-734dfd44f864.png)


if you hover over the twitch icon, it displays the list of online streamers, and their infos

![panel](https://user-images.githubusercontent.com/22444128/152661226-51ab2a53-c616-4fdb-9923-bdf2af325d1d.png)

### Notification
When a stream goes live, it will show a desktop nofication

#### If you have zenity
It will display a notification with a button
If you click on the button, it will open the stream on mpv if it's installed, or it will open in your browser

#### If you don't have zenity
It will display a notification with notify-send like this

## Why I did this ?
I didn't want to have a twitch account, but to be able to know which of my streamers on twitch was on live

# Todo
- make it works with twitch api token
