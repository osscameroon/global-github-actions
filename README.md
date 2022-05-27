# global-github-actions

All github actions that we run for the entire github organisation

## Github actions list

- [recommend_yotas_issues](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/notify_on_pull_request_open.yaml)
    Send a message to the telegram group/channel of OssCameroon for available yotas to earn on some Pulls Requests.
- [report_contributions](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/notify_on_pull_request_open.yaml)
    Send the list to the telegram group/channel of OssCameroon for contributions rate per developers in the organisation.
- [report_number_of_yotas](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/notify_on_pull_request_open.yaml)
    Send yotas amount per developers in the organisation.
- [report_opencollective](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/notify_on_pull_request_open.yaml)
    Send opencollective contributions for donations to the telegram group/channel of OssCameroon.
- [report_quiz](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_a_quiz.yaml)
    A quiz bot that will print some quiz questions with options in the telegram chat group.
- [social_media_message_scheduler](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/social_media_message_scheduler.yaml)
    A github action to schedule messages on twitter, telegram
- [report_quote](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_quotes.yaml)
    Using a small quote api to return some random programming quote.
- [report_jobs](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_jobs.yaml)
    Using an open jobs api to fetch some positions and propose that in osscameroon group chat.


## [notify_on_pull_request_open](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/notify_on_pull_request_open.yaml)

Send a message to the telegram channel whenever a new pull request is openened/created.

### Usage

On your repository create a `.github/workflows/notify_on_pull_request_open.yaml` file.
Then copy and paste in your newly created file the content bellow.

```
name: notify of pull_request creation
on:
  pull_request_target:
    types: [ opened ]
    branches:
      - main

jobs:
  notify:
    uses: osscameroon/global-github-actions/.github/workflows/notify_on_pull_request_open.yaml@main
    secrets:
      telegram_channel_id: ${{ secrets.TELEGRAM_OSSCAMEROON_CHANNEL_ID }}
      telegram_token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
```

You can use [this file](https://github.com/osscameroon/global-github-actions/blob/HEAD/.github/workflows/notify_on_pull_request_open.yaml) as reference
