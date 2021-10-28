#!/bin/bash

set -e

# We make the request and save response in json file
echo $(curl -s 'https://opencollective.com/osscameroon.json') > opencollective_info.json

# We parse and extract datas...
balance=$(($(cat opencollective_info.json | jq -r '.balance')/100))
yearlyIncome=$(($(cat opencollective_info.json | jq -r '.yearlyIncome')/100))
backersCount=$(cat opencollective_info.json | jq -r '.backersCount')


# We build our message
echo "" #for telegram format

current_date=$(date)
echo "$current_date"
echo ""
echo "OpenCollective report"
echo ""
echo ""
echo "🧐 Hello there !"
echo ""
echo "Some statistics for our opencollective contributions (yeah, money/'nkap'):"
echo ""
echo "\`\`\`"
echo "------------------------------------------"
echo ""
echo "[💶] TODAY’S BALANCE : ${balance}€"
echo "[💸] ESTIMATED ANNUAL BUDGET : ${yearlyIncome}€"
echo "[😎] BACKERS/CONTRIBUTORS : ${backersCount}"
echo ""
echo "------------------------------------------"
echo "\`\`\`"
echo ""
echo "Huges Thanks for donations, trust and support 🥳🙇🙏 !!!"
echo ""
echo "If you want to contribute too, feel free to donate here : https://opencollective.com/osscameroon !"
echo "There is no 'small money', each donations count a lot😉!"
echo ""
echo "Full details about transactions, expenses... available here : https://opencollective.com/osscameroon/transactions"

echo "" #for telegram format
