# TentD Omnibus

Bundled collection of [status](https://github.com/tent/tent-status)
and [admin](https://github.com/tent/tent-admin) apps and the [0.3 reference server](https://github.com/tent/tentd/tree/0.3).

## Setup

### ENV

Name           | Required | Description
--------       | -------- | -----------
USERNAME       | Required | Username you want to signin with
PASSPHRASE     | Required | Passphrase you want to signin with (must be encrypted through `rake encrypt_passphrase[passphrase]`)
URL            | Required | URL pointing to this app
SESSION_SECRET | Required | Random string for session cookie secret
DATABASE_URL   | Required | Postgres database url
REDIS_URL      | Required | Redis url
TENT_ENTITY    | Optional | Defaults to the mounted path of tentd

**tentd**

See the [tentd README](https://github.com/tent/tentd/blob/0.3/README.md) for details and additional configuration options.

**status**

See the [status README](https://github.com/tent/tent-status/blob/master/README.md) for details and additional configuration options.

**admin**

See the [admin README](https://github.com/tent/tent-admin/blob/master/README.md) for details and additional configuration options.

### Booting it up

Assuming you have the appropriate ENV varibles set,

```shell
git clone git://git.github.com/tent/tentd-omnibus
bundle
bundle exec rake assets:precompile
createdb tentd
bundle exec rake db:migrate
bundle exec unicorn -p 8080
```

will start an [instance of tentd](http://localhost:8080/tent) with
pre-compiled and pre-authed instances of [status](http://localhost:8080/status) and [admin](http://localhost:8080/admin).

### Heroku

```shell
heroku create --addons heroku-postgresql:dev,rediscloud:20
heroku pg:promote $(heroku pg | head -1 | cut -f2 -d" ")
heroku labs:enable user-env-compile
git push heroku master
heroku run bundle exec rake db:migrate
heroku config:add SESSION_SECRET=$(openssl rand -hex 16 | tr -d '\r\n') USERNAME=admin PASSPHRASE=$(heroku run bundle exec rake encrypt_passphrase[passphrase] | egrep "^[^\s]+$" | tr -d '\r\n') URL=$(heroku info -s | grep web_url | cut -f2 -d"=" | sed 's/http/https/' | sed 's/\/$//') REDIS_URL=$(heroku config:get REDISCLOUD_URL | tr -d '\r\n')
heroku open
```
