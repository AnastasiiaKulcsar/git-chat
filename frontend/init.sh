#!/usr/bin/env bash

source functions.sh

# This function clear chat history and remove all folders in backend/users but save oldchat to chat.bak
print_red "Bist du sicher? Du wirst den gesamten Chatverlauf verlieren!  (ja/nein) : "
read -p "" reset_chat_agree
if [[ $reset_chat_agree == "ja" ]]
then     
    cat chat >> chat.bak
    > ~/workspace/git-chat-solem2/backend/chat
    rm -rf users/{*,.*}
    echo "We saved the history to chat.back"
    sleep 3
fi
