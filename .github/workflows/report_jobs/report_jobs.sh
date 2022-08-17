#!/bin/bash

set -e

# This method will fetch avaialble jobs from https://documenter.getpostman.com/view/18545278/UVJbJdKh
# For now we filter on tags having software or Remote or Dev....
get_available_jobs(){
    curl -s -L 'https://arbeitnow.com/api/job-board-api?limit=15' | \
    jq '.data[] | {
        location: .location,
        remote: .remote,
        url: .url,
        tags: .tags,
        title: .title,
        company_name: .company_name
    }'
    # | select(.tags[] | (
    #     select(. | contains("IT")) or
    #     select(. | contains("Software")) or
    #     select(. | contains("Web Development"))
    # ))'
}

item=0
limit=10
ret=$(get_available_jobs)
current_date=$(date)
echo "$current_date"
echo ""
echo ""
echo "😎 Helloooo people \\!"
echo ""
echo "We found some Interesting Job opportunities \\!"
echo ""
echo $ret | jq -r '[.location, .remote, .url, .title, .company_name, .tags] | @tsv' | \
while IFS=$'\t' read -r location remote url title company_name tags ; do
    echo ""
    echo "Title: \`$title\`"
    echo "Remote: $remote"
    echo "Location: $location"
    echo "Company: $company_name"
    echo "Tags: $tags"
    echo "Url: $url"
    echo ""
    echo "\\-\\-\\-\\-\\-\\-\\-\\-\\-\\-\\-\\-\\-\\-\\-\\-\\-\\-\\-"
    echo ""
    echo ""
    ((item=item+1))
    if (( (item + 1) > limit )); then
        break
    fi
done
echo ""
