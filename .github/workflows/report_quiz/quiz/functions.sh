# To escapes some stupid quotes
escp(){
    echo -e \"$(printf '%q' "$*")\"
}

# to fetch programming questions
get_quiz_questions_answers() {
    curl https://quizapi.io/api/v1/questions -G -d apiKey=${QUIZAPI_KEY} -d limit=1 -d difficulty=easy 2>/dev/null | \
    jq '.[] | {question: .question, A: .answers.answer_a, B: .answers.answer_b, C: .answers.answer_c, D: .answers.answer_d, E: .answers.answer_e, F: .answers.answer_f, tags: [.tags[].name] | join(" "), multiple_correct_answers: .multiple_correct_answers}'
}

# A curl to send message in a chat
send_message(){
    payload="{\"chat_id\": ${TELEGRAM_CHAT_ID}, \"text\": $1}"
    echo "msg-payload: ${payload}"
    echo "----------------------------------------------"

    curl -s -d "${payload}" -H "Content-Type: application/json" -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage
}

# A curl to send the poll
send_poll(){
    payload="{\"chat_id\": ${TELEGRAM_CHAT_ID}, \"question\": \"😏 Can you guess the good answer(s) ?\n🤪 Don't worry it's anonymous !\",\"options\": [$1],\"allows_multiple_answers\": $2}"
    echo "poll-payload: ${payload}"
    echo "----------------------------------------------"

    curl -s -d "${payload}" -H "Content-Type: application/json" -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPoll
}

# Propose a quiz
propose_quiz(){
    ret=$(get_quiz_questions_answers)
    question=$(jq -r '.question' <<< ${ret})
    A=$(jq -r '.A // empty' <<< ${ret})
    B=$(jq -r '.B // empty' <<< ${ret})
    C=$(jq -r '.C // empty' <<< ${ret})
    D=$(jq -r '.D // empty' <<< ${ret})
    E=$(jq -r '.E // empty' <<< ${ret})
    F=$(jq -r '.F // empty' <<< ${ret})
    tags=$(jq -r '.tags' <<< ${ret})
    multiple_correct_answers=$(jq -r '.multiple_correct_answers' <<< ${ret})
    msg="👨🏾💻 Quiz Time !?\n${question}\nHints: ${tags}"
    # We add the answer if not null
    # We suppose that at this point we will have at least 2 options valid
    options=$([ -z "$A" ] || echo $(escp "$A"))$([ -z "$B" ] || echo ,$(escp "$B"))$([ -z "$C" ] || echo ,$(escp "$C"))$([ -z "$D" ] || echo ,$(escp "$D"))$([ -z "$E" ] || echo ,$(escp "$E"))$([ -z "$F" ] || echo ,$(escp "$F"))
    echo ${options}
    
    echo "msg: ${msg}"
    echo "----------------------------------------------"
    echo "options: ${options}"
    echo "----------------------------------------------"

    # We verify if the options don't exceed the max length
    if [ ${#A} -gt ${MAX_LENGTH} ] || [ ${#B} -gt ${MAX_LENGTH} ] || [ ${#C} -gt ${MAX_LENGTH} ] || [ ${#D} -gt ${MAX_LENGTH} ] || [ ${#E} -gt ${MAX_LENGTH} ] || [ ${#F} -gt ${MAX_LENGTH} ]; then
        echo "[skipped] one option exceed the max max_length ${MAX_LENGTH}"
        return 1
    else
        send_message "$(escp ${msg})"
        send_poll "${options}" ${multiple_correct_answers}

        return 0
    fi
}
