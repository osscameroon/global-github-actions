import tweepy
import os

consumer_key = os.getenv("consumer_key")
consumer_secret = os.getenv("consumer_secret")
api_key = os.getenv("api_key")
api_secret = os.getenv("api_secret")

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(api_key, api_secret)
api = tweepy.API(auth)


def post_tweet(text):
    if text:
        print("Twitter publisher: \n", text)
        print("Lenght: ", len(text))
        api.update_status(text)


def twitter_publisher(message):
    if message is None:
        raise Exception("Error message not found")

    text = None
    if "message" in message:
        text = message["message"]
    else:
        if "message-en" in message:
            text = message["message-en"]
        if "message-fr" in message:
            text = message["message-fr"]
    post_tweet(text)
