curl -H "Authorization: token $GITHUB_TOKEN"  \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/orgs/$org/repos | jq

exit 1
