#!/bin/bash

set -e

#get_org_unarchived_repos print out organisation list of not archived repositories
#The list should not contain archived repos like the former repo osscameroon-blog
#After checking GitHub API to list organization repositories(https://docs.github.com/en/rest/repos/repos#list-organization-repositories), we'll filter with the condition archived==false
#param: organisation name
get_org_unarchived_repos() {
	org=$1
	curl -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github+json"  https://api.github.com/orgs/$org/repos 2>/dev/null | jq '.[] | select(.archived == false) | .url' -r
}

#get_repository_issues print out organisation list of repositories
# param: repository name
get_repository_opened_issues() {
	repo=$1
	page=$2
	curl -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github+json"  $repo/issues\?state\=open\&per_page\=100\&page\=$page 2>/dev/null | jq 'map(select(.labels[].name | contains("Yotas"))) | map({issue: .html_url, title: .title, author: .user.login, yotas: .labels[] | select( .name | contains("Yotas") ) | .name})'
}

ORG=osscameroon
REPOSITORIES=$(get_org_unarchived_repos $ORG)

#get repositories issues
for repo in $REPOSITORIES; do
# 	echo "Getting issues for repository: $repo"

	page=1
	while true; do
# 		echo "page: $page"
# 		echo "repo: $repo"
		ret=$(get_repository_opened_issues $repo $page)
		if [[ -z "$ret" ]]; then
			break
		fi
		if [[ "$ret" = "[]" ]]; then
			break
		fi

		echo "$ret"
		((page++))

		#sleep to not break the GitHub api limit
		sleep 1
	done

	#sleep to not break the GitHub api limit
	sleep 1
done
