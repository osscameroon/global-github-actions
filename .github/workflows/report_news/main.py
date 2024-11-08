import json
from hashlib import sha1
import random
import os
from typing import Iterable
from urllib.request import urlopen
from urllib.error import HTTPError
from urllib.parse import quote as urlquote
import xml.etree.ElementTree as ET
import re

TECH_GRIOT_API_URL = 'https://techgriot.co/feed'
NEWS_API_URL = 'https://newsapi.org/v2/top-headlines?sources=techcrunch'
NEWS_API_KEY = os.getenv('NEWS_API_KEY')
REPORT_NEWS_HASHES = 'report_news.hash'
PEEF_SITEMAP_URL = 'https://peef.dev/sitemap.xml'
MAX_ARTICLES = 10


def fetch_tech_crunch():
    """
    Fetching data from techcrunch
    """

    url = f'{NEWS_API_URL}&apiKey={NEWS_API_KEY}'

    with urlopen(url) as response:
        body = response.read()
        body_json = json.loads(body)

        articles = []
        for a in body_json['articles']:
            articles.append({
                'author': a.get('author', None),
                'title': a.get('title', None),
                'link': a.get('url', None),
                'description': a.get('description', None),
                'pub_date': a.get('publishedAt', None),
            })

        return articles


def fetch_tech_griot() -> list:
    """
    fetching articles from techgriot
    """

    with urlopen(TECH_GRIOT_API_URL) as response:
        body = response.read()
        xml_raw = ET.fromstring(body)

        articles = []
        for a in xml_raw.findall('.//item'):
            articles.append({
                'title': a.find('./title').text,
                'link': a.find('./link').text,
                'description': a.find('./description').text,
                'pub_date': a.find('./pubDate').text,
            })

    return articles


def fetch_peef():
    """
    Fetching data from peef
    """

    url = f'{PEEF_SITEMAP_URL}'

    with urlopen(url) as response:
        body = response.read()

    xml_raw = ET.fromstring(body)

    articles = []
    for url in xml_raw.findall('{http://www.sitemaps.org/schemas/sitemap/0.9}url')[-MAX_ARTICLES:]:
        loc = url.find('{http://www.sitemaps.org/schemas/sitemap/0.9}loc')
        lastmod = url.find('{http://www.sitemaps.org/schemas/sitemap/0.9}lastmod')

        if loc is None or lastmod is None:
            continue

        link = re.sub(r'^http://', 'https://', urlquote(loc.text, safe=":/"))
        pub_date = lastmod.text

        # A peef article in under the form https://peef.dev/post/<author>/<slug>
        if not link.startswith("https://peef.dev/post/") or link.strip("/").count("/") != 5:
            continue

        author, title = link.split("/")[4:6]
        title = title.replace('-', ' ').capitalize()

        try:
            with urlopen(link) as response:
                body = response.read().decode()
            
            # Parse the HTML data
            description = re.findall(r"<article.*?>(.*?)</article>", body.replace('\n', ''))
            if not description:
                print("Error: Unable to parse the article", file=sys.stderr)
                continue

            description = description[0]
            # Clean the data
            description = re.sub(r"<.*?>", "", description).strip()[:255]
        except HTTPError as e:
            continue

        articles.append({
            'author': author,
            'title': title,
            'link': link,
            'description': description,
            'pub_date': pub_date,
        })

    return articles


def hash_it(info: dict) -> str:
    """
    This method takes as input a dictionnary, then dumps it into string
    and encode it before hashing it
    """
    return sha1(json.dumps(info).encode('utf-8')).hexdigest()

def existing_hash(givenews_hash: str, hashes: dict) -> bool:
    return givenews_hash in hashes.keys()

def extract_hash() -> dict:
    try:
        with open(REPORT_NEWS_HASHES, 'r') as hh:
            return {k.replace('\n', ''):{} for k in hh.readlines()}
    except FileNotFoundError as es:
        if not os.path.exists(REPORT_NEWS_HASHES):
            open(REPORT_NEWS_HASHES, 'w+')

        with open(REPORT_NEWS_HASHES, 'r') as hh:
            return {k.replace('\n', ''):{} for k in hh.readlines()}

def store_hashes(hashes: list):
    """
    We add a hash to the file
    """
    with open(REPORT_NEWS_HASHES, 'w') as hh:
        hh.write('\n'.join(hashes))

def build_news() -> Iterable:
    """
    We build news
    """
    result = {}
    news = fetch_tech_crunch() + fetch_tech_griot() +  fetch_peef()
    # we extract hashes from the file as a dict
    hashes = extract_hash()
    # From each iteration, we shuffle
    random.shuffle(news)

    max_iterations = MAX_ARTICLES
    while max_iterations > 0:
        for n in news:
            if len(result.keys()) == MAX_ARTICLES:
                break

            news_hash = hash_it(n)
            # We check if the hash is present in the keys from the result dictionnary
            # and we also check if the hash already exist in the list of hashes
            # extracted from the file
            if news_hash not in result.keys() and not existing_hash(news_hash, hashes):
                result[news_hash] = n
                hashes[news_hash] = n

        max_iterations -= 1

    store_hashes(list(hashes.keys()))
    return result.values()

def format_str():
    finalOutput = ""

    for article in build_news():
        finalOutput += "\n" + article['title'] + "\n\n" + article['description'][:100]
        finalOutput += "...\n> " + article['link']
        finalOutput += "\n-------------------------------------------\n"

    return finalOutput

"""
TODO:
    clean the hash file list
"""

if __name__ == '__main__':
    print(format_str())


