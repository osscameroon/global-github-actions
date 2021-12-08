#!/bin/bash

set -e


CHAT_ID=$1
TELEGRAM_BOT_TOKEN=$2
QUIZAPI_KEY=$3

<<<<<<< HEAD
# to fetch programming questions
get_quiz_questions_answers() {
    curl https://quizapi.io/api/v1/questions -G -d apiKey=$QUIZAPI_KEY -d limit=1 2>/dev/null | \
    jq '.[] | select(.multiple_correct_answers=="false") | {question: .question, A: .answers.answer_a, B: .answers.answer_b, C: .answers.answer_c, D: .answers.answer_d, E: .answers.answer_e, F: .answers.answer_f}'
=======
# We only want medium and easy questions
level=("medium" "easy")
rand=$[$RANDOM % ${#level[@]}]

# to fetch programming questions
get_quiz_questions_answers() {
    curl https://quizapi.io/api/v1/questions -G -d apiKey=$QUIZAPI_KEY -d limit=1 -d difficulty=${level[$rand]} 2>/dev/null | \
    jq '.[] | {question: .question, A: .answers.answer_a, B: .answers.answer_b, C: .answers.answer_c, D: .answers.answer_d, E: .answers.answer_e, F: .answers.answer_f}'
>>>>>>> feat(quiz): implemented a Quiz bot (#20)
}

# A curl to send message in a chat
send_message(){
    curl -s \
    -d "{\"chat_id\": $1, \"text\": \"$2\"}" \
    -H "Content-Type: application/json" -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
}

# A curl to send the poll
send_poll(){
    curl -s \
<<<<<<< HEAD
    -d "{\"chat_id\": $1, \"question\": \"😏 Can you guess the good answer ?\n🤪 Don't worry it's anonymous !\n\n\",\"options\": [\"🤔 Option A\",\"😯 Option B\",\"🤧 Option C\",\"🥴 Option D\",\"😑 Option E\",\"🤭 Option F\"]}" \
=======
    -d "{\"chat_id\": $1, \
            \"question\": \"😏 Can you guess the good answer(s) ?\n🤪 Don't worry it's anonymous !\n\n\",\
            \"options\": [\"🤔 Option A\",\"😯 Option B\",\"🤧 Option C\",\"🥴 Option D\",\"😑 Option E\",\"🤭 Option F\"]}" \
>>>>>>> feat(quiz): implemented a Quiz bot (#20)
    -H "Content-Type: application/json" -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendPoll
}

ret=$(get_quiz_questions_answers)
echo $ret | jq -r '[.question, .A, .B, .C, .D, .E, .F] | @tsv' | \
while IFS=$'\t' read -r question A B C D E F; do
    send_message $CHAT_ID "👨🏾‍💻 Quiz time !?\n\nQ: $question \n#oss_quiz_time"
<<<<<<< HEAD

    send_message $CHAT_ID "\nA: $A\nB: $B\nC: $C\nD: $D\nE: $E\nF $F\n\n#oss_quiz_time"

    send_poll $CHAT_ID

=======
    send_message $CHAT_ID "\nA: $A\nB: $B\nC: $C\nD: $D\nE: $E\nF $F\n\n#oss_quiz_time"
    send_poll $CHAT_ID
>>>>>>> feat(quiz): implemented a Quiz bot (#20)
    send_message $CHAT_ID "😇 It is allowed to discuss about it in the chat and exchange with others on what you think about it !\n\n#oss_quiz_time"
done
