REPORT QUIZ BOT
===

[![telegram github quiz](https://github.com/osscameroon/global-github-actions/actions/workflows/report_a_quiz.yaml/badge.svg)](https://github.com/osscameroon/global-github-actions/actions/workflows/report_a_quiz.yaml)

This workflow is to automate the management of the [osscameroon](https://osscameroon.com/) quiz competition.

Requirements
---

- An API KEY from [QuizAPI](https://quizapi.io).
- A bot token from [Telegram BotFather](https://core.telegram.org/bots/tutorial#introduction).
- [Jq](https://github.com/jqlang/jq) (>=1.6)
- [Bash](https://www.gnu.org/software/bash/)
- [git](https://git-scm.com/)

How to run this locally
---

1. Clone the repository

   ```bash
   git clone https://github.com/osscameroon/global-github-actions/
   ```

2. Move to the `report_quiz` folder

   ```bash
   cd .github/workflows/report_quiz
   ```

3. Run the following command to make a copy of the `env.example.sh` file

   ```bash
   cp env.example.sh env.sh
   ```

4. Edit the `env.sh` file with the necessary data

5. Setting up your bash terminal

   ```bash
   source main.sh
   ```

6. Now to test this bot, you can use the following commands

   ```bash
   # Starts a new quiz competition.
   . start_quiz_competition
   # Fetch user answers of the qizzes.
   . fetch_quiz_users_answers
   # Stop the current quiz competition and submit resutls.
   . stop_quiz_competition
   ```

Contributing
---

Please, feel free to contribute to make this bot better.

Useful resources
---

- A jq cheetsheet: https://gist.github.com/olih/f7437fb6962fb3ee9fe95bda8d2c8fa4
- A jq playground: https://jqplay.org/
- The telegram API docs: https://core.telegram.org/bots/api


