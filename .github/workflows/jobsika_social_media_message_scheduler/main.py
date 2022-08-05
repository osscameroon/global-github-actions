import yaml
import os
import random
from twitter import twitter_publisher
from telegram import telegram_group_publisher, telegram_channel_publisher

run_number = int(os.getenv("run_number"))
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

    # get a message index that depends on the run_number
    size = len(messages)
    print("size: ", size)
    n = list(range(0, size))
    seed = run_number - (run_number % size)
    random.Random(seed).shuffle(n)
    message = messages[n[run_number % size]]

    if "targets" in message:
        # make sure that we have uniq element per target
        targets = set(message["targets"])
        print("targets:", targets)
        for target in targets:
            if target in func_publishers:
                try:
                    func_publishers[target](
                        message=message,
                        media=message.get('media', None)
                    )
                except Exception as exc:
                    print(exc)
        print("\n")


if __name__ == "__main__":
    messages = get_messages()
    publish_messages(messages)
