#!/bin/bash

set -e

# load functions
source quiz/functions.sh

# load environement variables
source env.sh

mkdir -p database

if [ -z ${TELEGRAM_BOT_TOKEN} ]; then
	echo "TELEGRAM_BOT_TOKEN is not set!"
    exit
elif [ -z ${TELEGRAM_CHAT_ID} ]; then
	echo "TELEGRAM_CHAT_ID is not set!"
    exit
elif [ -z ${QUIZAPI_KEY} ]; then
	echo "QUIZAPI_KEY is not set!"
    exit
fi

# incomming parameters
skipped_quizzes=0
tempfile=$(tempfile)


while [ $skipped_quizzes -lt 3 ]; do
    # We verify if the quiz has been proposed successfully
    if propose_quiz > ${tempfile}; then
        # Save the quiz data in the database
        filename=$(jq -r '.poll_id' ${tempfile} -r)
        mv ${tempfile} database/${filename}.json
        break
    else
        skipped_quizzes=$(expr $skipped_quizzes + 1)
    fi
done
