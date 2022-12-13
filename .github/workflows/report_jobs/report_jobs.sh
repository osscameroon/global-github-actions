#!/bin/bash

set -e

# This method will fetch avaialble jobs from https://documenter.getpostman.com/view/18545278/UVJbJdKh
# For now we filter on tags having software or Remote or Dev....
get_available_jobs(){
    curl -s -L 'https://arbeitnow.com/api/job-board-api?limit=15' | \
    jq '.data[]
    | {location: .location, remote: .remote, url: .url, tags: .tags, title: .title, company_name: .company_name, description: .description[0:150]}
    | select(.tags[] | (
        select(. | contains("Remote")) or
        select(. | contains("IT Management")) or
        select(. | contains("Software / Web Development"))
    ))'
}


# The format of the message body
format_msg(){
    echo "\"Arbeitnow helps companies hire candidates with visa sponsorship / four day work week / remote opportunities.\""
    echo ""

    item=0
    limit=10
    ret=$(get_available_jobs)
    echo $ret | jq -r '[.location, .remote, .url, .title, .company_name, .description] | @tsv' | \
    while IFS=$'\t' read -r location remote url title company_name description; do
        echo $description

        echo "> $url"
        echo "Remote: $remote"
        echo "Location: $location"
        echo ""

        ((item=item+1))
        if (( (item + 1) > limit )); then
            break
        fi
    done
}


current_date=$(date)
echo "$current_date"
echo ""
echo "Hey there, i have some Jobs opportunities."
echo ""
format_msg
echo ""
