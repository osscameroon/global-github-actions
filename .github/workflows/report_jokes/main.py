import json
import urllib3

# documentation available here : https://sv443.net/jokeapi/v2/
JOKE_URL = 'https://v2.jokeapi.dev/joke/Programming?blacklistFlags=nsfw,religious,political,racist,sexist,explicit'


def fetch_joke() -> dict:
    """ We fetch the joke """
    http = urllib3.PoolManager()
    r = http.request('GET', JOKE_URL)
    return json.loads(r.data.decode('utf-8'))


def validate_joke(joke: dict) -> None:
    """ We want to validate the joke before rendering it"""
    assert isinstance(joke, dict) and joke['error'] is False, f'Error on joke fetched... {joke}'


def render_joke(joke: dict) -> None:
    """ We just render on stdout the joke"""
    validate_joke(joke)

    try:
        if joke.get('type') == 'single':
            joke_str = joke['joke']
        elif joke.get('type') == 'twopart':
            joke_str = f">> {joke['setup']} \n\n<< {joke['delivery']}"
        else:
            raise Exception(f'Unknow joke format {joke}')
    except KeyError as exc:
        raise KeyError(f'Unknow joke format, {joke}') from exc

    print('\n🙂 Hey there, a Joke for you !')
    print(f'\n{joke_str}\n')
    print('😂😂😂 did you get it ?')

if __name__ == '__main__':
    render_joke(
        fetch_joke()
    )
