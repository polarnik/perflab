# [Тестирование REST-сервиса с использованием Apache.JMeter](/2_rest-api.jmeter.md)

## REST-API WordPress

В нашем расположении имеется тестовый стенд.

Веб-интерфейс WordPress 5.1.1:

* http://wp.loadlab.ragozin.info/
* http://192.168.100.141


Панель администратора WordPress 5.1.1:

* http://wp.loadlab.ragozin.info/wp-admin/
    * логин: boss
    * пароль: boss
* http://192.168.100.141/wp-admin/

REST-API WordPress 5.1.1:

* <http://wp.loadlab.ragozin.info/wp-json/>


Также у WordPress есть демо-стенд с данными только для чтения:

* <https://demo.wp-api.org/wp-json/>
* <https://demo.wp-api.org/> - веб-интерфейс


### Документация

Документация в json-формате доступна по адресу:

* <http://wp.loadlab.ragozin.info/wp-json/wp/v2/> - по нашему сайту
* <https://api.w.org/> - в печатном виде
* <https://developer.wordpress.org/rest-api/reference/> - она же
* <https://wp-kama.ru/handbook/rest/wp-routes> - на русском языке

Её можно фильтровать по разделам, используя метод OPTIONS или фильтруя результаты вывода:

<http://wp.loadlab.ragozin.info/wp-json/wp/v2/posts?_method=OPTIONS>

```
curl -X GET     'http://lab-wp.ragozin.info/wp-json/wp/v2/'      | jq '."routes"."/wp/v2/users"'

curl -X OPTIONS 'http://lab-wp.ragozin.info/wp-json/wp/v2/users'

curl -X OPTIONS 'http://lab-wp.ragozin.info/wp-json/wp/v2/users' | jq
```

Но гораздо удобнее смотреть документацию в виде веб-страниц. Для этого на сайте wordpress.com есть раздел с документацией:

Документация на REST-API WordPress:

* <https://developer.wordpress.com/docs/api/>

Документация по основным методами REST-API WordPress на русском языке:

* <https://wp-kama.ru/handbook/rest/wp-routes>

#### Примечание про префикс `/sites/$site/` в <https://developer.wordpress.com/docs/api/>

При чтении документации с сайта developer.wordpress.com нужно учитывать, что префикс `/sites/$site/` на стенде lab-wp.ragozin.info отсуствует и не нужен.
И поэтому читая документацию на метод

* <https://developer.wordpress.com/docs/api/1.1/get/sites/%24site/posts/>
* GET /sites/$site<u>**/posts/**</u>
* Get a list of matching posts.

| Parameter| Value|
| -------- | ---- |
| Method |	GET |
|URL |	https://public-api.wordpress.com/rest/v1.1/sites/$site**<u>/posts/</u>**|
|Requires authentication? |	No |

Нужно будет вызывать просто метод:

* GET <u>**/posts/**</u>
* Get a list of matching posts.

| Parameter| Value|
| -------- | ---- |
| Method |	GET |
|URL |	http://lab-wp.ragozin.info/wp-json/wp/v2**<u>/posts/</u>**|
|Requires authentication? |	No |


Пример:

```
curl -X GET http://lab-wp.ragozin.info/wp-json/wp/v2/posts/
```
Пример с формированием вывода:
```
curl -X GET http://lab-wp.ragozin.info/wp-json/wp/v2/posts/ | jq
```
Пример с выводом только полей `title.rendered`, полученных с помощью JSON Path выражения и утилиты `jq`:
```
curl -X GET http://lab-wp.ragozin.info/wp-json/wp/v2/posts | jq '.[] | .title.rendered'
```

### Аутентификация


Часть методов требуют аутентификации. Например метод получения списка пользователей:

* https://developer.wordpress.com/docs/api/1.1/get/sites/%24site/users/

| Parameter| Value|
| -------- | ---- |
| Method |	GET |
|URL |	http://lab-wp.ragozin.info/wp-json/wp/v2**<u>/users/</u>**|
|Requires authentication? |	<u>**Yes**</u>|

Аутентификация может работать странно, но она есть:

* <http://lab-wp.ragozin.info/wp-json/wp/v2/users/1> для просмотра информации об администраторе сайта аутентифиация не требуется.
* <http://lab-wp.ragozin.info/wp-json/wp/v2/users/2> для просмотра информации о другом пользователе сайта нужна аутентификация.

#### Basic-аутентификация

Для вызова таких методов нужно передать логин и пароль. Например, для `curl` есть параметр `--user`, логин и пароль передаются в `curl` так:

```
# json:
curl --user boss:boss -X GET http://lab-wp.ragozin.info/wp-json/wp/v2/users
# json c форматированием:
curl --user boss:boss -X GET http://lab-wp.ragozin.info/wp-json/wp/v2/users | jq
# json только с полями id и name:
curl --user boss:boss -X GET http://lab-wp.ragozin.info/wp-json/wp/v2/users | jq '.[] | {id:.id, name: .name}'
```

Это Basic-аутентификация, также она может быть выполнена следующим способом, через заголовок запроса Authorization, в значении которого указывается тип Basic и через пробел значение пары "логин:пароль", закодированные в base64:

```
# token = Ym9zczpib3NzCg== (с переводом строки)
token=`echo "boss:boss" | base64`
curl -X GET http://lab-wp.ragozin.info/wp-json/wp/v2/users -H "Authorization: Basic $token"

# token = Ym9zczpib3Nz     (без перевода строки)
token=`echo -n "boss:boss"| base64`
curl -X GET http://lab-wp.ragozin.info/wp-json/wp/v2/users -H "Authorization: Basic $token"

# Или можно в явном виде передать строку boss:boss закодированную в base64:
curl -X GET http://lab-wp.ragozin.info/wp-json/wp/v2/users -H "Authorization: Basic Ym9zczpib3NzCg=="
curl -X GET http://lab-wp.ragozin.info/wp-json/wp/v2/users -H "Authorization: Basic Ym9zczpib3Nz"
```


### Передача параметров

Рассмотрим метод создания записи блога (post):

* <https://developer.wordpress.com/docs/api/1.1/post/sites/%24site/posts/new/>

#### POST /posts/new
##### Resource Information

| Parameter                | Value                                                       |
| -------------------------| ----------------------------------------------------------- |
| Method                   |GET                                                          |
| URL                      |http://lab-wp.ragozin.info/wp-json/wp/v2**<u>/posts/new</u>**|
| Requires authentication? |<u>**Yes**</u>                                               |


##### Request Parameters

| Parameter      | Type              | Description                         |
| -------------- | ----------------- | ----------------------------------- |
| date           | iso 8601 datetime |                                     |
| title          | html              |                                     |
| content        | html              |                                     |
| excerpt        | html              |                                     |
| slug           | string            |                                     |
| author         | string            |                                     |
| status         | string            |                                     |
| sticky         | bool              |                                     |
| categories     | array\|string     |                                     |
| tags           | array\|string     |                                     |
| format         | string            | default, standard, aside, chat, gallery, link, image, quote, status,  video, audio                                                     |
| featured_image | string            |                                     |
| media          | media             |                                     |
|                |                   |                                     |
|                |                   |                                     |
|                |                   |                                     |
|                |                   |                                     |
|                |                   |                                     |
|                |                   |                                     |
|                |                   |                                     |

## Практическая работа с JMeter

## Простейший сценарий

## Парсинг результатов запроса

## Использование переменных

## Сравнение компонентов Apache.JMeter

## Результаты тестирования

