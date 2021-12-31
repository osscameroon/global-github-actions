#!/bin/bash

set -e

# just to randomize the sort element, so that we have sometimes
# sorted by comments or sometimes sorted by reactions
sort_element=("comments" "reactions")
rand=$[$RANDOM % ${#sort_element[@]}]

#get_repository_issues print out organisation list of repositories
# param: repository name
get_open_projects_issues() {
	page=$1
    repo=https://api.github.com/repos/osscameroon/Open-Projects
	curl -H "Accept: application/vnd.github.v3+json" \
    $repo/issues\?sort=${sort_element[$rand]}\&direction=desc\&state\=open\&per_page\=10\&page\=$page 2>/dev/null | \
    jq '[limit(7;.[])] | .[] | {url: .url, user: .user.login, body: .body[0:300], comments: .comments, reactions: .reactions.total_count, c: .total_count}'
}

generate_msg(){
    # Loop and append the result in the JSON_PAYLOAD variable
    page=1
    JSON_PAYLOAD=""
    while true; do
        ret=$(get_open_projects_issues $page)

        echo $ret | jq -r '[.url, .user, .body, .reactions, .comments] | @tsv' | \
        while IFS=$'\t' read -r url user body reactions comments; do
            echo " \`\`\`"
            echo "by $user 💡"
            body=$(echo "$body" | tr \# \& | tr \' ,)
            printf "$body"
            echo " ...\`\`\`"
            echo "✋🏾reactions\\: $reactions"
            echo "💬comments\\: $comments"
            echo ""
        done

        if [[ -z "$ret" ]]; then
            break
        fi
        ((page++))

        #sleep to not break the GitHub api limit
        sleep 2
    done
}

# # # We build our message
current_date=$(date)
echo "$current_date"
echo ""
echo "Open Ideas/Projects report"
echo ""
echo ""
echo "😎 Helloooo genius people \\!"
echo ""
echo "This is the list of great ideas/projects pending in OssCameroun \\:"
generate_msg
echo "Don t forget, you can \\:"
echo "\\>  Choose an idea, contribute in the chat or exchange with others \\!"
echo "\\>  Create your issue as a project you have in mind \\!"
echo "Feel free to create an idea \\(a provided template is available\\) or just read more [HERE](https://github.com/osscameroon/Open-Projects/issues) \\!"
echo "" #for telegram format
