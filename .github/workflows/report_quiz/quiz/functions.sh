MAX_LENGTH=100
BASE_DIR=$(dirname $(dirname "${BASH_SOURCE[0]}")..)

source "${BASE_DIR}/common/utils.sh"

# to fetch programming questions
get_quiz_questions_answers() {
    curl -s https://quizapi.io/api/v1/questions -G -d apiKey=${QUIZAPI_KEY} -d limit=1 -d difficulty=easy 2>/dev/stderr | \
    jq '.[] | {question: .question, answers, tags: [.tags[].name] | join(" "), multiple_correct_answers: .multiple_correct_answers, correct_answers}'
}

# A curl to send message in a chat
send_message(){
    payload="{\"chat_id\": ${TELEGRAM_CHAT_ID}, \"text\": $1}"
    # echo "msg-payload: ${payload}"
    # echo "----------------------------------------------"

    curl -s -d "${payload}" -H "Content-Type: application/json" -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage &>/dev/stderr
}

# Send the poll
send_poll(){
    payload="{\"chat_id\": ${TELEGRAM_CHAT_ID}, \"question\": \"😏 Can you guess the good answer(s) ?\n🤪 Don't worry it's anonymous !\",\"options\": [$1],\"allows_multiple_answers\": $2,\"is_anonymous\": 0}"
    # echo "poll-payload: ${payload}"
    # echo "----------------------------------------------"

    # Submit the quiz and download the quiz data.
    curl -s -d "${payload}" -H "Content-Type: application/json" -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPoll 2>/dev/stderr | \
    jq '.result | {message_id, date, poll_id: .poll.id}'
}

# Propose a quiz
propose_quiz(){
    quiz_data=$(get_quiz_questions_answers)
    question=$(jq -r '.question' <<< ${quiz_data})
    A=$(jq -r '.answers.answer_a // empty' <<< ${quiz_data})
    B=$(jq -r '.answers.answer_b // empty' <<< ${quiz_data})
    C=$(jq -r '.answers.answer_c // empty' <<< ${quiz_data})
    D=$(jq -r '.answers.answer_d // empty' <<< ${quiz_data})
    E=$(jq -r '.answers.answer_e // empty' <<< ${quiz_data})
    F=$(jq -r '.answers.answer_f // empty' <<< ${quiz_data})
    tags=$(jq -r '.tags' <<< ${quiz_data})
    multiple_correct_answers=$(jq -r '.multiple_correct_answers' <<< ${quiz_data})
    msg="👨🏾💻 Quiz Time !?\n${question}\nHints: ${tags}"
    # We add the answer if not null
    # We suppose that at this point we will have at least 2 options valid
    options=$([ -z "$A" ] || echo $(escp "$A"))$([ -z "$B" ] || echo ,$(escp "$B"))$([ -z "$C" ] || echo ,$(escp "$C"))$([ -z "$D" ] || echo ,$(escp "$D"))$([ -z "$E" ] || echo ,$(escp "$E"))$([ -z "$F" ] || echo ,$(escp "$F"))
    
    # echo "msg: ${msg}"
    # echo "----------------------------------------------"
    # echo "options: ${options}"
    # echo "----------------------------------------------"

    # We verify if the options don't exceed the max length
    if [ ${#A} -gt ${MAX_LENGTH} ] || [ ${#B} -gt ${MAX_LENGTH} ] || [ ${#C} -gt ${MAX_LENGTH} ] || [ ${#D} -gt ${MAX_LENGTH} ] || [ ${#E} -gt ${MAX_LENGTH} ] || [ ${#F} -gt ${MAX_LENGTH} ]; then
        echo "[skipped] one option exceed the max max_length ${MAX_LENGTH}"
        return 1
    fi
    
    send_message "$(escp ${msg})"
    poll_data=$(send_poll "${options}" ${multiple_correct_answers})

    jq -s add <<< "${poll_data} ${quiz_data}"
}

# Get user submitted answers per poll
# Note that we consider just one answer per user per poll 
get_user_answers(){
    payload="{\"chat_id\": ${TELEGRAM_CHAT_ID}}"
    # echo "msg-payload: ${payload}"
    # echo "----------------------------------------------"

    curl -s -d "${payload}" -H "Content-Type: application/json" -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates 2>/dev/stderr | \
    jq '.result | map(select(.poll_answer and .poll_answer.user.is_bot == false)) | group_by(.poll_answer.poll_id) | map({key: .[0].poll_answer.poll_id, value: map({first_name: .poll_answer.user.first_name, username: .poll_answer.user.username, options_ids: .poll_answer.option_ids})}) | from_entries'
}

# Close a poll
close_poll(){
    payload="{\"chat_id\": ${TELEGRAM_CHAT_ID}, \"message_id\": $1}"
    # echo "msg-payload: ${payload}"
    # echo "----------------------------------------------"

    curl -s -d "${payload}" -H "Content-Type: application/json" -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/stopPoll &>/dev/stderr
}
