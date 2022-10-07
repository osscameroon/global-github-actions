import json
from urllib.request import urlopen
import xml.etree.ElementTree as ET

TECH_GRIOT = 'https://techgriot.co/feed'


def fetch_articles() -> list:
    """
    This function is responsible for fetching and
    parsing datas from techgrio
    """
    with urlopen(TECH_GRIOT) as response:
         body = response.read()

    xml_raw = ET.fromstring(body)

    articles = []
    for x in xml_raw.findall('.//item'):
        title = x.find('./title').text
        link = x.find('./link').text
        description = x.find('./description').text
        # author = x.find('./comments/following-sibling').text
        # author = x.find("./dc\:creator").text
        pub_date = x.find('./pubDate').text
        # post_id = x.find('./post&minus;id').text

        articles.append({
            'title': title,
            'link': link,
            'description': description,
            'pub_date': pub_date,
        })

    return articles

"""
TODO:

- ecrire un message contenant les articles de techgriot
- porte news_api code
- concatene tout ca dans un seul message
"""


if __name__ == '__main__':
    print(json.dumps(fetch_articles()))
