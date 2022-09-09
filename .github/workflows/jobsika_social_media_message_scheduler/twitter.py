import tweepy
import os

consumer_key = os.getenv("consumer_key")
consumer_secret = os.getenv("consumer_secret")
api_key = os.getenv("api_key")
api_secret = os.getenv("api_secret")

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(api_key, api_secret)
api = tweepy.API(auth)

def post_tweet(text, media=None):
    print("Twitter publisher: \n", text)
    print("Lenght: ", len(text))

    if not media:
        api.update_status(text)
    else:
        media_absolute_path = (
            f'{os.path.dirname(os.path.abspath(__file__))}'
            f'/res/medias/{media}'
        )
        print(f'{media=}')
        if os.path.exists(media_absolute_path):
            print(
                f'Media : {media_absolute_path}, '
                f'Size: {os.path.getsize(media_absolute_path)}'
            )
            # posting the tweet
            api.update_status_with_media(text, media_absolute_path)
        else:
            api.update_status(text)


def twitter_publisher(message, media=None):
    if message is None:
        raise Exception("Error message not found")

    if "message" in message:
        text = message["message"]
        post_tweet(text, media)
    else:
        if "message-en" in message:
            text = message["message-en"]
            post_tweet(text, media)
        if "message-fr" in message:
            text = message["message-fr"]
            post_tweet(text, media)
