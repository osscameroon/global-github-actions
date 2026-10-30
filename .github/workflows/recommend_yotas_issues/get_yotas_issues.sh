#!/bin/bash

set -e

./get_opened_issues.sh > opened_issues.json
issues=$(cat opened_issues.json | jq -s 'reduce .[] as $x ([]; . + $x)')

if [[ "$(echo "$issues" | jq 'length')" = "0" ]]; then
	echo "There are no open issues with Yotas right now.
Keep an eye on osscameroon’s repositories, new ones will come soon 👉 https://github.com/osscameroon"
	exit 0
fi

echo "You can contribute to osscameroon’s opensource projects and earn some Yotas
for you to spend on our shop 👉 https://miniyotas.osscameroon.com/shop.

Checkout this issues :
"
echo "$issues" | jq -r '.[] | "Title: \(.title)\nPrice: \(.yotas)\nIssue Url: \(.issue)\n"'
