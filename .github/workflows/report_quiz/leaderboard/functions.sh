# compute the user total score from more than one quiz_data
compute_total_score(){
    jq -s 'map((.correct_answers | map(.)) as $answers | .user_answers | map(.score=(.options_ids | map(select($answers[.] == "true")) | length)-(.options_ids | map(select($answers[.] == "false")) | length) | del(.options_ids))) | add | group_by(.first_name) | map((map(.score) | add) as $total_score | .[0] | del(.score) | .total_score=$total_score)' $@
}

# genarate a textual leaderboard with price
generate_leaderboard(){
    jq -r --argjson total_price 30000 '["1st", "2nd", "3rd", "4th", "5th"] as $rangs | ["🥇", "🥈", "🥉", "🎖️"] as $badges | group_by(-.total_score) | to_entries | map(.price=$total_price/((.key+1)*2)) | map(.key as $key | [([$rangs[.key], "PLACE", "-", .price, "yotas"] | join(" ")), (.value | map([$badges[$key], .first_name, "("+"@"+.username+")"] | join(" ")) | sort)] | flatten | join("\\n")) | join("\\n\\n")' $1
}