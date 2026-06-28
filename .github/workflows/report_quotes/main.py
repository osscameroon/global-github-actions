import hashlib
import json
import random
import urllib3

# The previous https://raw.githubusercontent.com/skolakoda/programming-quotes-api/master/Data/quotes.json
# 404s; we now hit ZenQuotes (free, no-auth JSON) and map its shape onto ours.
QUOTE_URL = 'https://zenquotes.io/api/random'


def fetch_quotes() -> list:
    """We fetch the quote list, made a method for this so that the refactoring
    process will not been hard, we should just change this method
    implementation
    yeah we could have use requests here but that need to install requests
    lib... and am too lzy to setup a Makefile and requirements stuff for all of
    that, let's go with urlib for now
    """
    http = urllib3.PoolManager()
    r = http.request('GET', QUOTE_URL)

    # Raise a clear error on non-2xx so we don't quietly fall through to
    # json.loads and get a misleading "Extra data" parse error if the API
    # returns plain text like "404: Not Found".
    if r.status != 200:
        raise RuntimeError(
            f'Failed to fetch quote from {QUOTE_URL}: '
            f'HTTP {r.status} — {r.data.decode("utf-8", errors="replace").strip()}'
        )

    try:
        data = json.loads(r.data.decode('utf-8'))
    except json.JSONDecodeError as exc:
        raise RuntimeError(
            f'Failed to parse quote API response as JSON from {QUOTE_URL}: '
            f'{r.data.decode("utf-8", errors="replace").strip()}'
        ) from exc

    # Some endpoints wrap the quote; normalise to a list of dicts.
    if isinstance(data, dict):
        data = [data]

    # ZenQuotes returns a list of {'q': text, 'a': author, 'h': html, ...}; map
    # it into the {en, author, id} shape that validate_quote/render_quote use.
    return [
        {
            'en': item.get('q'),
            'author': item.get('a'),
            'id': hashlib.sha1(
                f"{item.get('q', '')}|{item.get('a', '')}".encode('utf-8')
            ).hexdigest(),
        }
        for item in data
    ]


def validate_quote(quote: dict) -> None:
    """ We want to validate the quote before rendering it"""
    assert isinstance(quote, dict) and all(k in ['en', 'author', 'id'] for k in quote.keys()), f'Error on quote keys... {quote}'


def render_quote(quote: dict) -> None:
    """ We just render on stdout the quote"""
    validate_quote(quote)

    print('\n📖 Random Programming Quote !')
    print(f'\n"{quote.get("en")}"\n')
    print(f'From {quote.get("author")}\n')


def pick_quote(quotes: list) -> dict:
    """A custom method to 'pick' the quote we want"""
    return random.choice(quotes)


if __name__ == '__main__':
    render_quote(
        pick_quote(
            fetch_quotes()
        )
    )
