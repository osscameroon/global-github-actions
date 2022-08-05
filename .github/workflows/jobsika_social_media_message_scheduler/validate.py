import yaml
from twitter_text import parse_tweet

MESSAGE_FILE = "./res/messages.yaml"


def get_messages():
    with open(MESSAGE_FILE, "r") as file:
        try:
            return yaml.safe_load(file)
        except yaml.YAMLError as err:
            print(err)


def check_validity(text):
    if not text:
        raise Exception("Error: text is empty")

    ret = parse_tweet(text).asdict()
    if not ret["valid"]:
        raise Exception("Error: message is invalid: {0}: {1}".format(ret, text))


def validate_twitter(messages):
    for message in messages:
        if "message" in message:
            text = message["message"]
            check_validity(text)

        if "message-en" in message:
            text = message["message-en"]
            check_validity(text)

        if "message-fr" in message:
            text = message["message-fr"]
            check_validity(text)


def validate(messages):
    twitter_messages = [m for m in messages if "twitter" in m["targets"]]
    validate_twitter(twitter_messages)


if __name__ == "__main__":
    messages = get_messages()
    validate(messages)
    print("All good, your messages are valid !")
