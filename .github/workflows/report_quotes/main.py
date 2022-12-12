from random import randint
import json
import urllib3

QUOTE_URL = 'https://raw.githubusercontent.com/skolakoda/programming-quotes-api/master/Data/quotes.json'


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
    return json.loads(r.data.decode('utf-8'))


def validate_quote(quote: dict) -> None:
    """ We want to validate the quote before rendering it"""
    assert isinstance(quote, dict) and all(k in ['en', 'author', 'id'] for k in quote.keys()), f'Error on quote keys... {quote}'


def render_quote(quote: dict) -> None:
    """ We just render on stdout the quote"""
    validate_quote(quote)

    print('\n📖 Random Programming Quote \\!')
    print(' \\`\\`\\`')
    print(f'{quote.get("en")}')
    print(' \\`\\`\\`')
    print(f'From {quote.get("author")}\n')


def pick_quote(quotes: list) -> dict:
    """A custom method to 'pick' the quote we want"""
    return quotes[randint(0, len(quotes))]


if __name__ == '__main__':
    render_quote(
        pick_quote(
            fetch_quotes()
        )
    )
