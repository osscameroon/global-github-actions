package main

import (
	"log"
	"os"
)

func main() {

	// How to use it ?
	// report_news news_api telegram_token chat_id
	NEWS_API_KEY := os.Args[1]
	TELEGRAM_BOT_TOKEN := os.Args[2]
	CHAT_ID := os.Args[3]

	arcticles, err := FetchArticles(NEWS_API_KEY)
	if err != nil {
		log.Println(err)
	}

	message := "Good Morning OssCameroon members 🌤 !\nI have some tech news for you today !" + arcticles + "\nHave a great day !"

	log.Println("[-] Sending to oss :\n" + message)
	SendMessageToTelegram(CHAT_ID, TELEGRAM_BOT_TOKEN, message)
}
