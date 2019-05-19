#!/bin/bash

for i in {1..10}
do
author="author_email=owasp@yandex.ru&author_name=owasp"
comment="content=$i. Current date `date`"

curl --user boss:boss -d "post=1&$author&$comment&status=approve" \
    -X POST http://wp.loadlab.ragozin.info/wp-json/wp/v2/comments

done