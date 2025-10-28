# TODO: for a better code structure (software design) ->
# place functions here

source config.sh

welcome() {
    clear
    cat $baseFolder/backend/welcome
    sleep $splashDelay
}

output_chat() {
    clear
    echo "Our chat:

    "
    cat $chat_file 
    echo "

    "
}

inform_string(){
        echo "if you want see commands of chat, enter: /help

        
    Enter your message: "
}

list_commands(){
    print_green "
    /help - show commands
    /exit - exit chat
    /stats - show histogramm of messages
    /resetChat - clean chat messages (it saves chat history to chat.bak)
    /shareFile - put the file into users/folders
    /sendMail - send e-mail to everyone in chat (who has e-mails)
    /afk - user left for a while before 'Datetime'
    /tbn - show stistics about chat
    "
    
    echo "
    press ENTER to return to chat
    "
    read -p ""
}



# print red
print_red(){
    echo -e "\e[31m$1\e[0m"
}

# print green
print_green(){
    echo -e "\e[32m$1\e[0m"
}

# print blue
print_blue(){
    echo -e "\e[34m$1\e[0m"
}

# make histogramm (works)
make_hist(){
    clear
    echo "
    "
    # pipeline from leccion
    # cat ~/workspace/git-chat-solem2/backend/test_chat | cut -d' ' -f1 | tr -s '\n' | tr -d '[:punct:]' | sort | uniq -c
    cat $chat_file |          #stdout chat
    grep -a "^..*>>" |           #take strings wich begin with ..*>> these are users' messages
    cut -d' ' -f1 |           #take first word, delimiter - space
    tr -d '.' |               #remove .
    sort | uniq -c |          #sort and count (-c) uniq
    awk '{ printf "\033[32m%20s: ", $2; for(i=1; i<=$1; i++) printf "#"; print "\033[0m" }' #$1 = count; $2 = uniq username 
        
    echo "
    press ENTER to return to chat
    "
    read -p ""
}

#share file with people in chat (works)
shareFile(){
    read -p "Type path to file which you want share (with filename): " pathToFile
    filename=$(basename "$pathToFile")
    cat $chat_filet |               #stdout chat
    grep "^..*>>" |                 #use strings with messages
    cut -d' ' -f1 |                 #divide string using spaces
    tr -d '.' |                     #remove . from string
    sort | uniq |                   #sort and takes uniq users
    while read user
    do
        #echo $baseFolder/backend/users/$user
        mkdir -p $baseFolder/backend/users/$user         #make folder of user in backend/users
        cp $pathToFile $baseFolder/backend/users/$user/  #copy there shared file
        echo "File shared with user: $user"
        sleep 0.5
    done
    read -p "Push ENTER"
    echo "" >> $chat_file
    print_blue "$username shared file $filename. Check your folders" >> $chat_file
    echo "" >> $chat_file
}

#write a message - how long will user absent (works)
afk(){
    read -p "How long will you be not in chat (min): " minutes

    #return_time=$(date -d "+$minutes minutes" "+%Y-%m-%d %H:%M:%S")  #time of return with Date
    return_time=$(date -d "+$minutes minutes" "+%d.%m.%y %H:%M")           #time of return 
    echo "" >> $chat_file
    print_green "$username left for $minutes minutes, he will return at $return_time" >> $chat_file
    echo "" >> $chat_file
}

#tbn
show_stats(){
    clear
    echo "
    
    "
    print_blue "===========Message statistics==========="
    echo ""
    # find longest and shortest messages
    shortest_message=$(LC_ALL=C grep -a "^..*>>" "$chat_file" |                      #take only messages
                       tr -cd '\11\12\15\40-\176' |
                       awk -F'>> ' '{print length($2), $1 ">> " $2}' |      #find length of messsage (after >>)
                       sort -n |                                            #sort
                       head -n 1)                                           #take first
    longest_message=$(LC_ALL=C grep -a "^..*>>" "$chat_file" |                       #the same
                      tr -cd '\11\12\15\40-\176' |
                      awk -F'>> ' '{print length($2), $1 ">> " $2}' |
                      sort -n |         
                      tail -n 1)                                            #take last

    # find length and text of shortest message
    shortest_length=$(echo "$shortest_message" | awk '{print $1}')
    shortest_text=$(echo "$shortest_message" | cut -d ' ' -f2-)

    # find length and text of longest message
    longest_length=$(echo "$longest_message" | awk '{print $1}')
    longest_text=$(echo "$longest_message" | cut -d ' ' -f2-)

    # output result
    print_blue "===========The shortest and the longest messages==========="
    echo ""
    print_green "The shortest message: $shortest_text ($shortest_length chars)"
    print_green "The longest message: $longest_text ($longest_length chars)"
    echo ""

    print_blue "===========Activity per days==========="
    echo ""
    grep -a "^..*>>" $chat_file | 
    awk -F'(' '{print $2}'|
    awk -F' ' '{print $1}'|
    sort|
    uniq -c|
    while read message_count day
    do
    print_green "$day were $message_count messages"
    done 
    echo ""

    print_blue "===========Activity of users===========" 
    echo ""
    grep -a "^..*>>" $chat_file | 
    awk -F'(' '{print $1}'|
    tr -d '.' |               #remove .
    sort | uniq -c |
    awk '{ printf "\033[32m%20s: ", $2; for(i=1; i<=$1; i++) printf "#"; print "\033[0m" }'
    echo ""

    print_blue "===========Message leaderboard==========="
    echo ""
    grep -a "^..*>>" $chat_file | 
    awk -F'(' '{print $1}'|
    tr -d '.'|
    sort| uniq -c| sort -nr | head -n 3|
    while read count user
    do
    print_green "User $user typed $count messages"
    done
    echo ""

    print_blue "===========The shortest and the longest usernames==========="
    shortest_name=$(grep -a "^..*>>" $chat_file | 
    awk -F'(' '{print $1}'|
    tr -d '.'|tr -d ' ' |
    sort | uniq |
    awk '{print length($0), $0}' |
    sort | head -n 1 |
    awk '{print "The shortest name is " $2 ". It has " $1 " chars"}')
    print_green "$shortest_name"

    longest_name=$(grep -a "^..*>>" $chat_file | 
    awk -F'(' '{print $1}'|
    tr -d '.'|tr -d ' ' |
    sort | uniq |
    awk '{print length($0), $0}' |
    sort | tail -n 1 |
    awk '{print "The longest name is "$2". It has "$1" chars"}')
    print_green "$longest_name"
    echo ""

    print_blue "===========Active users (not AFK):==========="
    echo ""
    print_green "The users, which are absent"
    # change date formate to Unix time to compare 
    formatted_current_time=$(echo "$current_time" | awk -F' ' '{split($1, a, "."); print a[3] "-" a[2] "-" a[1] " " $2}')
    current_time_seconds=$(date -d "$formatted_current_time" +"%s")

    grep -v "^..*>>" $chat_file | 
    grep -v "^$" | 
    grep "left for" |
    awk -F' ' '{print $1, $10 " " $11}' |
    while read user date time
    do
        #echo $current_time_seconds
        users_time=$(echo $date && echo $time)
        formated_users_time=$(echo "$users_time" |                  #transform here problem format (green and with .)
                            sed ':a;N;$!ba;s/\n/ /g' | 
                            tr -d '\033[0m' |
                            awk -F' ' '{split($1, a, "."); print a[3] "-" a[2] "-" a[1] " " $2}')
        users_time_seconds=$(date -d "$formated_users_time" +"%s")
        #echo $users_time_seconds
        if [[ "$users_time_seconds" -gt "$current_time_seconds" ]]; then
            print_green "$user"
        fi        
    done
    print_green "Other users are active"

    read -p ""
}

sendMail(){
    #parameters to connect to linuxVM
    USER="castor"
    HOST="34.121.34.212"
    PATH_TO_KEY="/home/solem2/.ssh/mykeys/castor-linuxVM-rsa-key"
    REMOTE_PATH="/home/castor/SendMail/"

    #input path to file, message for letter, subject of letter
    read -p "Type path to file which you want share (with filename): " pathToFile
    read -p "Enter your massage here: " bodyOfLetter
    read -p "Enter subject of letter: " subjectOfLetter
    filename=$(basename "$pathToFile")

    #write this file to linuxVM
    scp -i "$PATH_TO_KEY" "$pathToFile" "$USER@$HOST:$REMOTE_PATH"


    cat $chat_file |                #stdout chat
    grep "^..*>>" |                 #use strings with messages
    cut -d' ' -f1 |                 #divide string using spaces and take first
    tr -d '.' |                     #remove . from string
    sort | uniq |                   #sort and takes uniq users
    while read user
do
    # Check, is there such username in passwd
    getent passwd $user &>/dev/null
    if [ $? -eq 0 ]; then
        # print information about user
        echo "Sending e-mail: $user"
        
        # get email of user
        TO=$(getent passwd $user | cut -d ',' -f4 | cut -d ':' -f1)
        
        # use ssh to send email
        ssh -i "$PATH_TO_KEY" "$USER@$HOST" bash <<EOF
        # send mail with sendmail
        SENDMAIL="/usr/sbin/sendmail"

        # collect MIME
        (
        echo "Subject: $subjectOfLetter"
        echo "From: sender@example.com"
        echo "To: $TO"
        echo "MIME-Version: 1.0"
        echo "Content-Type: multipart/mixed; boundary=\"boundary\""
        echo ""
        echo "--boundary"
        echo "Content-Type: text/plain; charset=\"utf-8\""
        echo ""
        echo "$bodyOfLetter"
        echo ""
        echo "--boundary"
        echo "Content-Type: application/octet-stream; name=\"$filename\""
        echo "Content-Disposition: attachment; filename=\"$filename\""
        echo "Content-Transfer-Encoding: base64"
        echo ""
        base64 "$REMOTE_PATH$filename"
        echo "--boundary--"
        ) | \$SENDMAIL "$TO"

        # check was sending succesfull
        if [ \$? -eq 0 ]; then
            echo "The letter was successfull sent!"
        else
            echo "Error with sending a letter"
        fi
EOF

    else
        echo "User: $user does not exist in the system. Cannot send him e-mail"
    fi
    sleep 2
done


    ssh -i "$PATH_TO_KEY" "$USER@$HOST" bash <<EOF
    rm "$REMOTE_PATH$filename"
EOF
}





input_message(){
    if read -t $message_delay user_input #check. if massaged nothing during 10 sec - go next circle of while 
    then
        if [[ $user_input == /* ]]; then 
            case $user_input in
                "/help") list_commands ;;
                "/exit") exit ;;
                "/resetChat") $baseFolder/frontend/init.sh;;
                "/shareFile") shareFile ;;
                "/afk") afk;;
                "/stats") make_hist;;
                "/tbn") show_stats;;
                "/sendMail") sendMail;;
                *) print_red "Error: such command $user_input doesn't exist"; sleep $error_delay;;
            esac
        
        else
            # add to file with chat history
            echo "..$username ($current_time)>> $user_input" >> $chat_file
        fi
        
    else 
        continue 
    fi    
}

# EOF 
