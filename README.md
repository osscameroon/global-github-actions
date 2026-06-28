# global-github-actions

All github actions that we run for the entire github organisation

## Github actions list

- [hermes_open_project_recommendation](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/hermes_open_project_recommendation.yaml)
    Daily post of an open-source project recommendation to the OssCameroon Telegram channel and Twitter timeline.
- [jobsika_social_media_message_scheduler](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/jobsika_social_media_message_scheduler.yaml)
    Monthly cron that publishes a scheduled message to the Jobsika Twitter account using dedicated credentials.
- [notify_on_broken_link_detected](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/notify_on_broken_link_detected.yaml)
    Manually triggerable workflow that scans OssCameroon websites for broken links and reports any failures to Telegram.
- [notify_on_issue_open](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/notify_on_issue_open.yaml)
    Reusable workflow that posts a Telegram message whenever a new issue is opened in a consuming repository.
- [notify_on_pull_request_open](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/notify_on_pull_request_open.yaml)
    Reusable workflow that posts a Telegram message whenever a new pull request is opened in a consuming repository.
- [recommend_yotas_issues](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/recommend_yotas_issues.yaml)
    Sends the list of available yotas issues to the OssCameroon Telegram channel and group, helping newcomers find work.
- [report_a_quiz](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_a_quiz.yaml)
    Posts programming quiz questions with options to the Telegram group every 10 hours (at least two per day).
- [report_contributions](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_contributions.yaml)
    Runs monthly (or on manual dispatch) to post the contributions rate per developer in the organisation to the Telegram channel and group.
- [report_jokes](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_jokes.yaml)
    Posts a daily programming joke, fetched from a free joke API, to the Telegram group.
- [report_jobs](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_jobs.yaml)
    Posts job openings fetched from an open jobs API to the OssCameroon remote-jobs Telegram group every Monday.
- [report_news](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_news.yaml)
    Posts daily tech news headlines to the Telegram channel, with deduplication via a hash file committed back to the repo.
- [report_number_of_yotas](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_number_of_yotas.yaml)
    Posts the total count of yotas earned per developer in the organisation to the Telegram channel and group.
- [report_open_projects](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_open_projects.yaml)
    Posts the list of currently open OssCameroon projects to the Telegram channel and group.
- [report_opencollective](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_opencollective.yaml)
    Posts OpenCollective contributions and donor info to the Telegram channel and group.
- [report_quotes](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/report_quotes.yaml)
    Posts a daily random programming quote, fetched from a small quote API, to the Telegram group.
- [social_media_message_scheduler](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/social_media_message_scheduler.yaml)
    Schedules messages from a YAML catalog and publishes them to Twitter and Telegram on Tuesday, Thursday and Saturday.
- [validate_message_scheduler_messages](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/validate_message_scheduler_messages.yaml)
    Pull-request validator that ensures the `social_media_message_scheduler` messages stay schema-compliant.


## [notify_on_pull_request_open](https://github.com/osscameroon/global-github-actions/blob/main/.github/workflows/notify_on_pull_request_open.yaml)

Send a message to the telegram channel whenever a new pull request is openened/created.

### Usage

On your repository create a `.github/workflows/notify_on_pull_request_open.yaml` file.
Then copy and paste in your newly created file the content bellow.

```yaml
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


![Alt](https://repobeats.axiom.co/api/embed/543b48955b6c028475b2c10d945c24714a0e52f3.svg "Repobeats analytics image")

