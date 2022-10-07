## REPORT NEWS

A small cli that fetch news data from newsapi.org and populate tha on OssCameroon group/channel Telegram !

### REQUIREMENTS

- golang (>=1.6 recommended)
- api keys (news_api, telegram_token and chat_id)

### HOW TO LAUNCH

```bash
# generate the binary with this command
go build

# then run the program by passing those parameters to the cli tool
report_news news_api telegram_token chat_id
```
