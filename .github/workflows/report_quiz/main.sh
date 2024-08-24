#!/bin/bash

set -e

# load functions
source quiz/functions.sh
source leaderboard/functions.sh

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

# inform about a new round of quiz
start_quiz_competition(){
    # TODO
    return 1
}

# send a quiz
send_quiz(){
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

# update quiz data based on user answers submission
fetch_quiz_user_answers(){
    # get previous quiz user answers
    user_answers=$(get_user_answers)

    # we save the quiz user answers
    for quiz_data_file in $(ls database/*.json); do
        poll_id=$(cut -d '.' -f 1 <(basename ${quiz_data_file}))
        quiz_user_answers=$(jq ".[\"${poll_id}\"]" <<< ${user_answers})
        # update quiz_data in ensuring unqie answer per user
        jq ".user_answers = ((.user_answers // []) + ${quiz_user_answers} | unique_by(.username))" ${quiz_data_file} > ${tempfile}
        mv ${tempfile} ${quiz_data_file}
    done
}

# stop the current round of quiz
stop_quiz_competition(){
    quiz_data_files=$(ls database/*.json || return)

    # stop all the active quizzes
    for quiz_data_file in ${quiz_data_files}; do
        close_poll $(jq -r '.message_id' ${quiz_data_file})
    done

    # compute score and generate leaderboard
    send_message "$(escp $(compute_total_score ${quiz_data_files} | generate_leaderboard))"

    # move all the current quiz_data in the archive folder
    timestamp=$(date +%s)
    mkdir -p archive/${timestamp}
    mv ${quiz_data_files} archive/${timestamp}
}