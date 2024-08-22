#!/bin/bash

set -e

# load functions
source quiz/functions.sh

# load environement variables
source env.sh

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
MAX_LENGTH=100
skipped_quizzes=0


while [ $skipped_quizzes -lt 3 ]; do
    # We verify if the quiz has been proposed successfully
    if propose_quiz; then
        break
    else
        skipped_quizzes=$(expr $skipped_quizzes + 1)
    fi
done

