#!/bin/bash

set -e

#get_repository_issues print out organisation list of repositories
# param: repository name
get_open_projects_issues() {
	page=$1
    repo=https://api.github.com/repos/osscameroon/Open-Projects
	curl -H "Accept: application/vnd.github.v3+json" \
    $repo/issues\?sort=comments\&direction=desc\&state\=open\&per_page\=100\&page\=$page 2>/dev/null | \
    jq '.[] | {url: .url, user: .user.login, body: .body[0:100], comments: .comments, reactions: .reactions.total_count}'
}

generate_msg(){
    # Loop and append the result in the JSON_PAYLOAD variable
    page=1
    JSON_PAYLOAD=""
    while true; do
        ret=$(get_open_projects_issues $page)

        echo $ret | jq -r '[.url, .user, .body, .reactions, .comments] | @tsv' | \
        while IFS=$'\t' read -r url user body reactions comments; do
            echo "\`\`\`"

            echo "By: $user"
            body=$(echo "$body" | tr \# \& | tr \' ,)
            printf "$body"
            echo "..."
            echo "✋🏾: $reactions"
            echo "💬: $comments"
            
            echo "\`\`\`"

            echo "[------------CHECK HERE------------]($url)"
            echo ""
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
echo ""
echo "Open Projects report"
echo ""
echo ""
echo "😎 Helloooooo \\!"
echo ""
echo "This is the list of great ideas/projects pending in OssCameroun :"
echo ""
generate_msg
echo "You can choose an idea, contribute in the chat with your ideas or exchange with others \\!"
echo "If you have a project or an idea in mind, anything \\!"
echo "Feel free to create an issue [HERE](https://github.com/osscameroon/Open-Projects/issues), a provided template is available for you \\!"
echo "" #for telegram format
