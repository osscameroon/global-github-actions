#!/bin/bash

set -e

BASE_DIR=$(dirname "${BASH_SOURCE[0]}")
DATABASE_DIR="${BASE_DIR}/database"
ARCHIVE_DIR="${BASE_DIR}/archive"
TEMPFILE="$(mktemp)"

# load functions
source "${BASE_DIR}/common/utils.sh"
source "${BASE_DIR}/quiz/functions.sh"
source "${BASE_DIR}/leaderboard/functions.sh"

# load environement variables
source "${BASE_DIR}/env.sh"

mkdir -p "${BASE_DIR}/database"

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

# determine round
get_current_round(){
    if [ -d ${ARCHIVE_DIR} ]; then
        expr $(ls ${ARCHIVE_DIR} | wc -l) + 1
    else
	echo 1
    fi
}

# inform about a new round of quiz
start_quiz_competition(){
    message="🏆 OSSCameroon Quiz Competition, Round $(get_current_round): Submissions\n\n

QuizBot is now ready to accept submissions for the OSSCameroon Quiz Competition, Round.\n\n

Q: How to participate\n
A: QuizBot will send quizzes daily, you should check frequently the messages in the OSS Cameroun telegram group.
"""
    
    send_message "$(escp ${message})"
}

# send a quiz
send_quiz(){
    while [ $skipped_quizzes -lt 3 ]; do
        # We verify if the quiz has been proposed successfully
        if propose_quiz > ${TEMPFILE}; then
            # Save the quiz data in the database
            filename=$(jq -r '.poll_id // empty' ${TEMPFILE} -r)
            if [ ! -z "${filename}" ]; then
                mv ${TEMPFILE} "${DATABASE_DIR}/${filename}.json"
            fi
            break
        else
            skipped_quizzes=$(expr $skipped_quizzes + 1)
        fi
    done
}

# update quiz data based on user answers submission
fetch_quiz_user_answers(){
    test $(ls ${DATABASE_DIR}/*.json | wc -l) -eq 0 && return 0
    # get previous quiz user answers
    user_answers=$(get_user_answers)

    # we save the quiz user answers
    for quiz_data_file in $(ls ${DATABASE_DIR}/*.json); do
        poll_id=$(cut -d '.' -f 1 <(basename ${quiz_data_file}))
        quiz_user_answers=$(jq ".[\"${poll_id}\"]" <<< ${user_answers})
        # update quiz_data in ensuring unqie answer per user
        jq ".user_answers = ((.user_answers // []) + ${quiz_user_answers} | unique_by(.username))" ${quiz_data_file} > ${TEMPFILE}
        mv ${TEMPFILE} ${quiz_data_file}
    done
}

# stop the current round of quiz
stop_quiz_competition(){
    test $(ls ${DATABASE_DIR}/*.json | wc -l) -eq 0 && return 0
    quiz_data_files=$(ls ${DATABASE_DIR}/*.json)

    # stop all the active quizzes
    for quiz_data_file in ${quiz_data_files}; do
        close_poll $(jq -r '.message_id' ${quiz_data_file})
    done

    # compute score
    quiz_data_score=$(compute_total_score ${quiz_data_files})
    # get first users and first price
    first_users=$(jq -r '.[0].value | map("@"+.username) | join(", ")' <<< ${quiz_data_score})
    first_price=$(jq -r '.[0].price' <<< ${quiz_data_score})
    # generate leaderboard
    leaderboard=$(generate_leaderboard <<< ${quiz_data_score})

    # announce the winners
    message="🏆 OSSCameroon Quiz Competition, Round $(get_current_round): Results\n\n

We are pleased to announce that ${first_users}, who boasts the best total score, have been promoted to 🥇1st PLACE and secured a ${first_price} yotas!\n\n

The Final Score for each submission was calculated based on their total correct quizzes.\n\n

Meet the winners!\n\n

${leaderboard}\n\n

Congratulations, and thank you to all who participated!\n\n

For further details, you can ask help in the OSS Cameroun telegram group.
"

    send_message "$(escp ${message})"

    # end the competition
    # move all the current quiz_data in the archive folder
    timestamp=$(date +%s)
    mkdir -p "${ARCHIVE_DIR}/${timestamp}"
    mv ${quiz_data_files} "${ARCHIVE_DIR}/${timestamp}"
}
