import yaml
from twitter import twitter_publisher
from telegram import telegram_group_publisher, telegram_channel_publisher

MESSAGE_FILE = "./res/messages.yaml"

func_publishers = {
    "twitter": twitter_publisher,
    "telegram_group": telegram_group_publisher,
    "telegram_channel": telegram_channel_publisher,
}


def get_messages():
    with open(MESSAGE_FILE, "r") as file:
        try:
            return yaml.safe_load(file)
        except yaml.YAMLError as err:
            print(err)


def publish_messages(messages):
    if messages is None:
        raise Exception("Error: No messages found!")

    for message in messages:
        if "targets" in message:
            # make sure that we have uniq element per target
            targets = set(message["targets"])
            print(targets)
            for target in targets:
                if target in func_publishers:
                    try:
                        func_publishers[target](message)
                    except Exception as exc:
                        print(exc)
            print("\n")


if __name__ == "__main__":
    messages = get_messages()
    publish_messages(messages)
