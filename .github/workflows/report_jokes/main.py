import json
import urllib3


# documentation available here : https://sv443.net/jokeapi/v2/
BLACK_LIST_SUBJECTS = ['nsfw', 'religious', 'political', 'racist', 'sexist', 'explicit']
JOKE_API_BASE_ROUTE = 'https://v2.jokeapi.dev'
JOKE_URL = f'{JOKE_API_BASE_ROUTE}/joke/Programming?blacklistFlags=' + ",".join(BLACK_LIST_SUBJECTS)


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

    try:
        validate_joke(joke)

        if joke.get('type') == 'single':
            joke_str = joke['joke']
        elif joke.get('type') == 'twopart':
            joke_str = f">> {joke['setup']} \n\n<< {joke['delivery']}"
        else:
            raise Exception(f'Unknow joke format {joke}')
    except KeyError as exc:
        raise KeyError(f'Unknow joke format, {joke}') from exc
    except AssertionError as exc:
        # for the validation error
        raise AssertionError from exc

    print('\n🙂 Hey there, a Joke for you !')
    print(f'\n{joke_str}\n')


if __name__ == '__main__':
    render_joke(
        fetch_joke()
    )
