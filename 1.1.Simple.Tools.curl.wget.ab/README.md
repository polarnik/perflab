# HTTP-запрос

Простое задание:

1. Запустить браузер Mozilla
2. Открыть консоль разработчика F12
1. Открыть страницу со стендом в браузере Mozilla: <http://wp.loadlab.ragozin.info>
3. Скопировать запрос на открытие главной страницы в виде curl-команды



# Простые консольные инструменты

## ab (Apache.Benchmark)

Инструмент для отправки статистических запросов.
Можно отправлять GET, HEAD, PUT, POST-запросы.
С указанием заголовков, тела запроса, прокси.


```
ab: wrong number of arguments
Usage: ab [options] [http[s]://]hostname[:port]/path
Options are:
    -n requests     Number of requests to perform
    -c concurrency  Number of multiple requests to make at a time
    -t timelimit    Seconds to max. to spend on benchmarking
                    This implies -n 50000
    -s timeout      Seconds to max. wait for each response
                    Default is 30 seconds
    -b windowsize   Size of TCP send/receive buffer, in bytes
    -B address      Address to bind to when making outgoing connections
    -p postfile     File containing data to POST. Remember also to set -T
    -u putfile      File containing data to PUT. Remember also to set -T
    -T content-type Content-type header to use for POST/PUT data, eg.
                    'application/x-www-form-urlencoded'
                    Default is 'text/plain'
    -v verbosity    How much troubleshooting info to print
    -w              Print out results in HTML tables
    -i              Use HEAD instead of GET
    -x attributes   String to insert as table attributes
    -y attributes   String to insert as tr attributes
    -z attributes   String to insert as td or th attributes
    -C attribute    Add cookie, eg. 'Apache=1234'. (repeatable)
    -H attribute    Add Arbitrary header line, eg. 'Accept-Encoding: gzip'
                    Inserted after all normal header lines. (repeatable)
    -A attribute    Add Basic WWW Authentication, the attributes
                    are a colon separated username and password.
    -P attribute    Add Basic Proxy Authentication, the attributes
                    are a colon separated username and password.
    -X proxy:port   Proxyserver and port number to use
    -V              Print version number and exit
    -k              Use HTTP KeepAlive feature
    -d              Do not show percentiles served table.
    -S              Do not show confidence estimators and warnings.
    -q              Do not show progress when doing more than 150 requests
    -l              Accept variable document length (use this for dynamic pages)
    -g filename     Output collected data to gnuplot format file.
    -e filename     Output CSV file with percentages served
    -r              Don't exit on socket receive errors.
    -m method       Method name
    -h              Display usage information (this message)
    -I              Disable TLS Server Name Indication (SNI) extension
    -Z ciphersuite  Specify SSL/TLS cipher suite (See openssl ciphers)
    -f protocol     Specify SSL/TLS protocol
                    (SSL2, TLS1, TLS1.1, TLS1.2 or ALL)
```


### Примеры сценариев с Apache.Benchmark

#### Главная страница сайта

##### Запрос страницы один раз

`ab http://wp.loadlab.ragozin.info`

##### Запрос страницы 200 раз

`ab -n 200 http://wp.loadlab.ragozin.info`

##### Запрос страницы 200 раз в 10 потоков:

`ab -n 200 -c 10 http://wp.loadlab.ragozin.info`

В каждом потоке будет по 20 запросов.
Во время тестирования будет установлено 200 подключений к серверу,
так как по умолчанию Keep-Alive отключен.

##### Запрос страницы 200 раз в 10 потоков с Keep-Alive:

`ab -n 200 -c 10 -k http://wp.loadlab.ragozin.info`

В каждом потоке будет по 20 запросов.
В момент начала работы будет установлено 10 подключений к серверу,
эти подключения будут использоваться на протяжении всего теста.

##### Отправка (POST) комментария к статье

```
echo -n "post=1" > /tmp/post.txt
echo -n "&author_email=owasp@yandex.ru" >> /tmp/post.txt
echo -n "&author_name=owasp" >> /tmp/post.txt
echo -n "&content=Current date `date`" >> /tmp/post.txt
echo -n "&status=approve" >> /tmp/post.txt

ab -n 1 -k -p /tmp/post.txt -A boss:boss -T 'application/x-www-form-urlencoded' -m POST http://wp.loadlab.ragozin.info/wp-json/wp/v2/comments
```

## wget

wget -S --limit-rate=20m --progress=dot:mega --output-document=/dev/null

wget -S --limit-rate=20m --progress=dot:mega \
	--header "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:44.0) Gecko/20100101 Firefox/44.0" \
	--header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
	--header "Accept-Language: ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3" \
	--header "Accept-Encoding: gzip, deflate" \
	--output-document=/dev/null

## curl

### REST-запрос на отображение страницы hello-world

`curl http://wp.loadlab.ragozin.info/wp-json/wp/v2/posts?slug=hello-world`

### REST-запрос на добавление комментария к статье hello-world

```
author="author_email=owasp@yandex.ru&author_name=owasp"
comment="content=Current date `date`&status=approve"

curl --user boss:boss -d "post=1&$author&$comment" -X POST http://wp.loadlab.ragozin.info/wp-json/wp/v2/comments
```


