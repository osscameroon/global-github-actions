package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"log"
	"net/http"
)

const NEWS_API_URL = "https://newsapi.org/v2/top-headlines?sources=techcrunch"
const TELEGRAM_API_URL = "https://api.telegram.org/bot"

// FetchArticles to fetch all articles from the api
func FetchArticles(apiKey string) (string, error) {
	resp, err := http.Get(NEWS_API_URL + "&apiKey=" + apiKey)
	if err != nil {
		log.Fatal("[x] ooopsss an error occurred")
		return "", errors.New("[x] error : url unreachable")
	}
	defer resp.Body.Close()

	var aResp Response
	if err := json.NewDecoder(resp.Body).Decode(&aResp); err != nil {
		log.Fatal("[x] error : Unable to decode the json response")
		return "", errors.New("[x] error : Unable to decode the json response")
	}

	return aResp.TextOutput(7), nil
}

// SendMessageToTelegram to send a messahe on oss channel or group
func SendMessageToTelegram(chat_id string, telegram_bot_token string, message string) bool {

	json_payload := map[string]string{"chat_id": chat_id, "text": message}
	json_data, err := json.Marshal(json_payload)

	if err != nil {
		log.Fatal(err)
		return false
	}

	resp, err := http.Post(
		TELEGRAM_API_URL+telegram_bot_token+"/sendMessage",
		"application/json",
		bytes.NewBuffer(json_data),
	)

	if err != nil {
		log.Fatal(err)
		return false
	}

	var res map[string]interface{}

	json.NewDecoder(resp.Body).Decode(&res)
	return true
}
