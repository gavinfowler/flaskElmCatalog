# Flask and Elm Catalog

This is a project to create a catalog with a Flask backend and an Elm frontend.

## Links

### Flask

[https://github.com/miguelgrinberg/REST-tutorial/blob/master/rest-server-v2.py](https://github.com/miguelgrinberg/REST-tutorial/blob/master/rest-server-v2.py)
[https://blog.miguelgrinberg.com/post/restful-authentication-with-flask](https://blog.miguelgrinberg.com/post/restful-authentication-with-flask)
[https://alligator.io/nodejs/solve-cors-once-and-for-all-netlify-dev/](https://alligator.io/nodejs/solve-cors-once-and-for-all-netlify-dev/)

### Elm

[https://elmprogramming.com/](https://elmprogramming.com/)

### Elasticsearch

[https://elasticsearch-py.readthedocs.io/en/master/](https://elasticsearch-py.readthedocs.io/en/master/)
[https://elasticsearch-dsl.readthedocs.io/en/latest/](https://elasticsearch-dsl.readthedocs.io/en/latest/)

run elasticsearch with

```sh
docker run -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.2.1
```

run flask with

```sh
python3 api.py
```

start elm with

```sh
elm init
```

run elm with

```sh
elm make src/HomePage.elm --output elm.js
```
