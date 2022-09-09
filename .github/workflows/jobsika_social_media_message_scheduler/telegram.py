def telegram_group_publisher(message, media=None):
    if message is None:
        raise Exception("Error message not found")
    print("Telegram group publisher: \n", message)


def telegram_channel_publisher(message, media=None):
    if message is None:
        raise Exception("Error message not found")
    print("Telegram channel publisher: \n", message)
