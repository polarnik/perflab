#!/bin/bash

for i in {1..100}
do
curl \
    'http://wp.loadlab.ragozin.info/' \
    -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
    -H 'Accept-Language: ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3' \
    --compressed \
    -H 'Connection: keep-alive' \
    -H 'Cookie: _ym_uid=1548859941871226753; _ym_d=1548859941; wp-settings-time-1=1557081907; wordpress_test_cookie=WP+Cookie+check' \
    -H 'Upgrade-Insecure-Requests: 1'
done