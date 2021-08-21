#!/bin/bash

set -e

CONTRIBUTION_FILE=contributions

get_issues_and_pr_contributions() {
	for c in $(cat $CONTRIBUTION_FILE | grep user | cut -d ":" -f 2 | tr -d " " | sort | uniq | sed 's/"//g'); do
		echo "$c,$(cat $CONTRIBUTION_FILE | grep $c -B 1 | grep issue | wc -l | tr -d " ")"
	done
}

get_pull_request_contributions() {
	for c in $(cat $CONTRIBUTION_FILE | grep user | cut -d ":" -f 2 | tr -d " " | sort | uniq | sed 's/"//g'); do
		echo "$c,$(cat $CONTRIBUTION_FILE | grep $c -B 1 | grep pulls | wc -l | tr -d " ")"
	done
}

get_total() {
	filename=$1
	cat $filename | cut -d "," -f 2 | xargs | sed -e 's/\ /+/g' | bc
}

filter_external() {
	file=$1
	cat $file | grep -vE '(elhmn|sherlockwisdom|gtindo|tericcabrel|Sanix-Darker|BorisGautier|DipandaAser|emmxl|Hawawou|FanJups)'
}


./get_user_contributions.sh > $CONTRIBUTION_FILE

get_issues_and_pr_contributions | grep ",0" -v > issues_and_pull_request_contributions.csv
total_issues_and_pr_contributions=$(get_total issues_and_pull_request_contributions.csv)

get_pull_request_contributions | grep ",0" -v > pull_request_contributions_only.csv
total_pr_contributions=$(get_total pull_request_contributions_only.csv)

filter_external issues_and_pull_request_contributions.csv > issues_and_pull_request_contributions_ext.csv
total_issues_and_pr_contributions_ext=$(get_total issues_and_pull_request_contributions_ext.csv)

filter_external pull_request_contributions_only.csv > pull_request_contributions_only_ext.csv
total_pr_contributions_ext=$(get_total pull_request_contributions_only_ext.csv)

echo "\`\`\`" #for telegram format

current_date=$(date)
echo "$current_date"
echo ""
echo "Oss cameroon contribution report"
echo ""
echo "1- Total contributions:"
echo ""
echo "$total_pr_contributions pull requests contributions only."
echo "$((total_issues_and_pr_contributions - total_pr_contributions)) issues contributions only."
echo "$total_issues_and_pr_contributions issues and pull request contributions."
echo ""
echo "2- External contributions:"
echo ""
echo "$total_pr_contributions_ext pull requests external contributions only."
echo "$((total_issues_and_pr_contributions_ext - total_pr_contributions_ext)) issues external contributions only."
echo "$total_issues_and_pr_contributions_ext issues and pull request external ontributions."
echo ""

termgraph issues_and_pull_request_contributions.csv  --title "Contributors"  --width=5
echo "Thanks for your contributions 🥳 🙇 🙌"
echo "\`\`\`" #for telegram format
