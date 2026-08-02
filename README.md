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


## How to launch these workflows

### 1) Scheduled workflows (automated)

Most workflows are started automatically by `on.schedule` and do **not** need a manual trigger.
GitHub evaluates schedules in UTC and only runs the workflow version on the default branch,
so schedule changes on a pull-request branch take effect only after they are merged into `main`.

- [hermes_open_project_recommendation.yaml](./.github/workflows/hermes_open_project_recommendation.yaml)
- [jobsika_social_media_message_scheduler.yaml](./.github/workflows/jobsika_social_media_message_scheduler.yaml)
- [recommend_yotas_issues.yaml](./.github/workflows/recommend_yotas_issues.yaml)
- [report_a_quiz.yaml](./.github/workflows/report_a_quiz.yaml)
- [report_jokes.yaml](./.github/workflows/report_jokes.yaml)
- [report_jobs.yaml](./.github/workflows/report_jobs.yaml)
- [report_news.yaml](./.github/workflows/report_news.yaml)
- [report_number_of_yotas.yaml](./.github/workflows/report_number_of_yotas.yaml)
- [report_open_projects.yaml](./.github/workflows/report_open_projects.yaml)
- [report_opencollective.yaml](./.github/workflows/report_opencollective.yaml)
- [report_quotes.yaml](./.github/workflows/report_quotes.yaml)
- [social_media_message_scheduler.yaml](./.github/workflows/social_media_message_scheduler.yaml)

`validate_message_scheduler_messages.yaml` runs on pull requests; it is not scheduled.

### 2) Manual dispatch workflows

These are the only workflows you can start manually from the GitHub UI or CLI:

```bash
gh workflow run notify_on_broken_link_detected.yaml
gh workflow run report_contributions.yaml
```

Optional:

```bash
gh workflow run notify_on_broken_link_detected.yaml --ref main
gh workflow run report_contributions.yaml --ref main
```

From the GitHub Actions UI, open each workflow page and click **Run workflow**.

### 3) Reusable workflows (consume from another repo)

`notify_on_issue_open.yaml` and `notify_on_pull_request_open.yaml` are defined as `workflow_call`.
They are not run directly with `gh workflow run`. They are invoked by another repository workflow via `uses: .../.github/workflows/<file>@<ref>`.

Example:

```yaml
jobs:
  notify:
    uses: osscameroon/global-github-actions/.github/workflows/notify_on_pull_request_open.yaml@main
    secrets:
      telegram_channel_id: ${{ secrets.TELEGRAM_OSSCAMEROON_CHANNEL_ID }}
      telegram_token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
```

### 4) Script entrypoint map (for local reproduction of launch logic)

Each workflow’s `run`/script flow usually maps to these local entrypoints:

- [social_media_message_scheduler](./.github/workflows/social_media_message_scheduler): `make run` and `make validate`
- [jobsika_social_media_message_scheduler](./.github/workflows/jobsika_social_media_message_scheduler): `make run` and `make validate`
- [report_news](./.github/workflows/report_news): `make -s run`
- [report_jokes](./.github/workflows/report_jokes/main.py): `python main.py`
- [report_quotes](./.github/workflows/report_quotes/main.py): `python main.py`
- [report_jobs](./.github/workflows/report_jobs/report_jobs.sh): `./report_jobs.sh`
- [report_open_projects](./.github/workflows/report_open_projects/get_open_projects.sh): `./get_open_projects.sh`
- [opencollective_contributions](./.github/workflows/opencollective_contributions/get_opencollective_info.sh): `./get_opencollective_info.sh`
- [report_contributions](./.github/workflows/report_contributions/get_contribution_report.sh): `./get_contribution_report.sh`
- [recommend_yotas_issues](./.github/workflows/recommend_yotas_issues/get_yotas_issues.sh): `./get_yotas_issues.sh`
- [report_quiz](./.github/workflows/report_quiz/report_quiz.sh): `./report_quiz.sh <GROUP_ID> <BOT_TOKEN> <QUIZAPI_KEY>`
- [report_number_of_yotas](./.github/workflows/members_yotas/extract.py): `python extract.py`
- [notify_on_issue_open](./.github/workflows/notify_on_issue_open/build_issue_notification.sh): `./build_issue_notification.sh "$GITHUB_EVENT_PATH"`
- [notify_on_pull_request_open](./.github/workflows/notify_on_pull_request_open/build_pull_request_notification.sh): `./build_pull_request_notification.sh "$GITHUB_EVENT_PATH"`
- [notify_on_broken_link_detected](./.github/workflows/notify_on_broken_link_detected/install_deps.sh): `./install_deps.sh` then `./run.sh`


### 5) Telegram group send gate (anti-flood for group chats)

Some group-send workflows now run a preflight check before posting to Telegram groups.
The check only allows a new bot message when Telegram has delivered at least one
human-authored update for that group in the sampled updates.

Behavior:

- Fetches recent updates from `getUpdates` for the target group chat.
- Restricts sampling to the last `N` received updates in that chat.
- Counts how many of those messages are from non-bot users.
- Sends only if the non-bot count is greater or equal to a minimum threshold.

Configuration is done with repository/organization variables (optional):

- `TELEGRAM_SEND_GATE_ENABLED` (`true`/`false`, default `true`)
- `TELEGRAM_SEND_GATE_LOOKBACK_MESSAGES` (default `5`)
- `TELEGRAM_SEND_GATE_MIN_HUMAN_MESSAGES` (default `1`)
- `TELEGRAM_SEND_GATE_ON_ERROR` (`skip` or `allow`, default `skip`)

`skip` on error means the bot is blocked and the message is not sent.
`allow` on error means the message is sent if Telegram API/dep checks fail.

Important: Telegram's Bot API does not provide a chat-history endpoint. This gate can
only inspect updates delivered to the bot, not independently retrieve the exact latest
messages visible in the group. For useful results, the bot must receive group messages
(for example, privacy mode disabled or the bot configured with the necessary access),
and no separate webhook/update consumer should drain those updates. If an exact
chat-history policy is required, use a dedicated Telegram client/service with explicit
history-read access instead of a bot-token-only workflow.

Script reference:

- `.github/workflows/telegram_send_gate.sh`
- it writes step outputs:
  - `telegram_send_gate`
  - `telegram_send_gate_reason`
  - `telegram_send_gate_human_messages`
  - `telegram_send_gate_sampled_messages`


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
