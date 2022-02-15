#!/bin/bash

set -e

# incomming parameters
CHAT_ID=$1
TELEGRAM_BOT_TOKEN=$2
QUIZAPI_KEY=$3

# To escapes some stupid quotes
escp(){
    echo -e \"$(printf '%q' "$1")\"
}

# to fetch programming questions
get_quiz_questions_answers() {
    curl https://quizapi.io/api/v1/questions -G -d apiKey=$QUIZAPI_KEY -d limit=1 -d difficulty=easy 2>/dev/null | \
    jq '.[] | {question: .question, A: .answers.answer_a, B: .answers.answer_b, C: .answers.answer_c, D: .answers.answer_d, E: .answers.answer_e}'
}

# A curl to send message in a chat
send_message(){
    payload="{\"chat_id\": $1, \"text\": \"${2}\"}"
    echo "msg-payload: $payload"
    echo "----------------------------------------------"

    curl -s -d "$payload" -H "Content-Type: application/json" -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
}

# A curl to send the poll
send_poll(){
    payload="{\"chat_id\": $1, \"question\": \"😏 Can you guess the good answer(s) ?\n🤪 Don't worry it's anonymous !\",\"options\": [$2]}"
    echo "poll-payload: $payload"
    echo "----------------------------------------------"

    curl -s -d "$payload" -H "Content-Type: application/json" -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendPoll
}

# The main function to be executed
main(){
    ret=$(get_quiz_questions_answers)
    echo $ret | jq -r '[.question, .A, .B, .C, .D] | @tsv' | \
    while IFS=$'\t' read -r question A B C D; do
        msg="👨🏾💻 Quiz Time !?\n${question}"
        echo ChoiceA: $A
        echo ChoiceB: $B
        echo ChoiceC: $C
        echo ChoiceD: $D
        # We add the answer if not null
        options=$(escp "$A"),$(escp "$B"),$(escp "$C"),$(escp "$D")

        echo "msg: $msg"
        echo "----------------------------------------------"
        echo "options: $options"
        echo "----------------------------------------------"

        send_message $CHAT_ID "$msg"
        send_poll $CHAT_ID "$options"
    done
}

main
