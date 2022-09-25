#!/bin/bash

set -e

# incomming parameters
report_file="report.txt"

# Track the broken links
blc_track(){
    python -m blc.blc -n -d .5 -b 5 $HOST > $report_file
    # We look for an error
    for i in $(cat $report_file | grep "\w* errors" -o | grep "[0-9]*" -o)
    do
      if [ $i != 0 ]
      then
        return 0
      fi
    done
    return 1
}

# A curl to send message in a chat
blc_report(){
    split $report_file -C 4K -x chunk

    for chunk in $(ls chunk*)
    do
        payload="{\"chat_id\": $TELEGRAM_CHAT_ID, \"text\": \"$(cat $chunk)\"}"
        curl -s -f -d "$payload" -H "Content-Type: application/json" -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
    done
}

# The main function to be executed
main(){
    echo "Starting of the tracking..."

    if blc_track
    then
        echo "Sending of the report..."
        blc_report
    else
        echo "No broken links."
    fi
}

main
