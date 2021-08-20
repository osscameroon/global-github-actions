#!/bin/bash

set -e

./get_opened_issues.sh > opened_issues.json
echo "You can contribute to osscameroon’s opensource projects and earn some Yotas
for you to spend on our shop 👉 https://miniyotas.osscameroon.com/shop.

Checkout this issues :
"
cat opened_issues.json | jq -s 'reduce .[] as $x ([]; . + $x)' | jq -r '.[] | "Title: \(.title)\nPrice: \(.yotas)\nIssue Url: \(.issue)\n"'
