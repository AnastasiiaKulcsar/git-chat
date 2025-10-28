#!/usr/bin/env bash

# TODO: use `git init --bare` to init backend
# git init --bare       #i didn't understand what for. it works without this command

# import functions script, relative to start of script
source functions.sh
source config.sh
#source ~/workspace/git-chat-solem2/frontend/sendmail.sh

# TODO: test for empty arg $1 (username), if empty ->
# display error message and exit

#enter username. I've made a little bit differeent. 
read -p "Enter username : " username

# if no name - exit script
if [ -z "$username" ]
then 
    print_red "Kein Name - Kein Chat"
    exit
fi

# add function to chek name in /home
if [[ $checkInHome = "true" ]]
    then
    if ! [ -d /home/$username/ ]
    then
    echo 'Du bist niht aus unseren Sandkasten'
    exit
    fi
fi


# TODO: use functions, e.g. display a welcome banner, with check config
if [[ $isSplash = "true" ]]
    then
    welcome
fi


# output file with chat to screen
output_chat

echo "

Welcome $username

"

# TODO: change into user message dir

while [ true ] 
do
    output_chat
    inform_string
    input_message
done

# EOF
