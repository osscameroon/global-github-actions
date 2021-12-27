import tweepy
import os

consumer_key = os.getenv("consumer_key")
consumer_secret = os.getenv("consumer_secret")
api_key = os.getenv("api_key")
api_secret = os.getenv("api_secret")

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(api_key, api_secret)
api = tweepy.API(auth)


def twitter_publisher(message):
    if message is None:
        print("Error message not found")
    text = message["message"]
    print("Twitter publisher: \n", text)
    print("Lenght: ", len(text))
    api.update_status(text)
