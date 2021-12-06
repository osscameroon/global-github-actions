#!/bin/bash

set -e

# We make the request and save response in json file
echo $(curl -s 'https://opencollective.com/osscameroon.json') > opencollective_info.json

# we get lit of members
echo $(curl -s 'https://opencollective.com/osscameroon/members/all.json') > opencollective_donators.json
# and
# Let's extract donator in a list
donator_list=( $(cat opencollective_donators.json | jq -r '.[].name') )

# We parse and extract datas...
balance=$(($(cat opencollective_info.json | jq -r '.balance')/100))
yearlyIncome=$(($(cat opencollective_info.json | jq -r '.yearlyIncome')/100))
backersCount=$(cat opencollective_info.json | jq -r '.backersCount')

# # # We build our message
echo "" #for telegram format

current_date=$(date)
echo "$current_date"
echo ""
echo "OpenCollective report"
echo ""
echo ""
echo "🧐 Hello there \\!"
echo ""
echo "Some statistics for our opencollective contributions :"
echo "\`\`\`"
echo "--------------------------------------"
echo ""
echo "[💶] TODAY’S BALANCE : ${balance}€"
echo "[💸] ESTIMATED ANNUAL BUDGET : ${yearlyIncome}€"
echo "[😎] BACKERS/CONTRIBUTORS : ${backersCount}"
echo ""
echo "--------------------------------------"
echo "\`\`\`"
echo "Thanks to our fantastics donators :"
echo ""
printf ' %s \n' "${donator_list[@]}" | sort -u
echo ""
echo "Huge Thanks for donations, trust and support 🥳🙇🙏 \\!\\!\\!"
echo ""
echo "If you want to contribute too, feel free to donate here : [CHECK_HERE](https://opencollective.com/osscameroon)"
echo "There is no 'small money', each donation count a lot"
echo ""
echo "Full details about transactions, expenses available here : [CHECK_HERE](https://opencollective.com/osscameroon/transactions)"

echo "" #for telegram format
