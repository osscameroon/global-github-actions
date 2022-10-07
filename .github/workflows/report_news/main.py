import requests
import xml.etree.ElementTree as ET

TECH_GRIOT = 'https://techgriot.co/feed'

r = requests.get(TECH_GRIOT)
xml_raw = ET.fromstring(r.text)

final_string = ''
for x in xml_raw.findall('.//item'):
    title = x.find('./title').text
    link = x.find('./link').text
    description = x.find('./description').text
    # author = x.find('./comments/following-sibling').text
    # author = x.find("./dc\:creator").text
    pub_date = x.find('./pubDate').text
    # post_id = x.find('./post-id').text
