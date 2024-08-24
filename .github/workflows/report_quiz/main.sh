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

# start a new quiz
start_quiz(){
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
}

fetch_quiz_data(){
    # get previous quiz user answers
    user_answers=$(get_user_answers)

    # we save the quiz user answers
    for quiz_data_file in $(ls database/*.json); do
        poll_id=$(cut -d '.' -f 1 <(basename ${quiz_data_file}))
        quiz_user_answers=$(jq ".[\"${poll_id}\"]" <<< ${user_answers})
        # update quiz_data in ensuring unqie answer per user
        jq ".user_answers = (.user_answers + ${quiz_user_answers} | unique_by(.username))" ${quiz_data_file} > ${tempfile}
        mv ${tempfile} ${quiz_data_file}
    done
}