#!/bin/bash

Ping_Sleep=600 # Interval in wich the script checks the servers, make this big
Network_Timeout=60 # how long should the ping wait for a responce, make this smaller then Ping_Sleep but big enough

checkServer () {
    port=$(echo $1 | cut -d ":" -f 2)
    header="\033[1;33m[Worker] $1:\033[0m"
    if [ ! -f /tmp/$port.lock ]; then
        notifyStat=0
    else
        notifyStat=1
    fi
    echo -e "$header Testing..."
    output=$(curl -m $Network_Timeout --http0.9 $1 2> /tmp/stat.$port.tmp)
    if [[ $? -ne 0 ]]; then
        if [[ $notifyStat -eq 0 ]]; then
            touch /tmp/$port.lock
            echo -e "$header \033[1;31m[FAIL]\033[0m Sending Email about fail."
            echo -e "$(cat /tmp/stat.$port.tmp)" | mail -s "$1 is down on $(date +"%D %T %Z")"  zaynebyard@gmail.com
        else
            echo -e "$header \033[1;31m[FAIL]\033[0m Server still offline."
        fi
    else
        if [[ $notifyStat -eq 1 ]]; then
            echo -e "$header \033[1;32m[PASS]\033[0m Sending Email about pass."
            echo -e "$output" | mail -s "$1 is back up on $(date +"%D %T %Z")"  zaynebyard@gmail.com
            rm /tmp/$port.lock 2> /dev/null
        else
            echo -e "$header \033[1;32m[PASS]\033[0m Server still online."
        fi
    fi
}

while true; do
    echo -e "\033[1;33m[Script] $(date +"%D %T %Z"):\033[0m Workers Dispached! Sleeping for $Ping_Sleep seconds before next ping, night night uwu..."

    # format like this:
    # checkServer ip:port &

    sleep $Ping_Sleep
done
