#!/bin/sh

FILE=$1


get_issues(){
    cat $FILE | jq -r '.[]
    |{
        id     : .issue.number | tostring,
        user   : .issue.user.login,
        url    : .issue.html_url,
        date   : .created_at,
        title  : .issue.title,
        body   : .issue.body,
        state  : .issue.state,
        labels : [.issue.labels[].name + ","] ,
    }'
}

# The main function to be executed
main(){
    ret=$(get_issues)
    echo $ret | jq -r '[.id, .user, .url, .date, .title, .body, .state, .labels[]] | @tsv' | \
    while IFS=$'\t' read -r id user url date title body state labels; do
        echo "A new issue was submitted by $user"
        echo ""
        echo "Title: $title"
        echo "Link: $url"
        echo "Description: "
        echo "$body"
        echo
        echo "Date  : $date"
        echo "State : $state"
        echo "Labels: $labels"
        echo "\- \- \- \- \- \- \- \- \- \- \- \- \- \- \- \-"
        echo
    done
}

main
