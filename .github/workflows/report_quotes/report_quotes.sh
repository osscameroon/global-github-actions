#!/bin/bash

set -e


get_quote(){
    res=$(curl -s -L https://programming-quotes-api.herokuapp.com/quotes/random | jq '{a: .author, q: .en}')
    echo $res
}

result=$(get_quote)
author=$(echo $result | jq '.a')
quote=$(echo $result | jq '.q')

echo ""
echo "📖 Random Programming Quote \\!"
echo " \`\`\`"
echo "$quote"
echo " \`\`\`"
echo "From $author"
echo ""

