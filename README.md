# Setup development environment

## Install infrastructure services

Right now, the whole project only depends on PostgresSQL.

You could install it locally or by docker compose.

```
docker compose up
```

## Install Language Suppport

We use Ruby, Python, NodeJS for this project.

for Mac OS, it is handy to use mise to manage python/ruby/nodejs to manage multiple version.

1. install and activate mise

```
# Check detail document here:
# https://mise.jdx.dev/getting-started.html

# install
curl https://mise.run | sh

# activate
mise activate

# activate when you are using zshrc
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc

```

2. Install language support

```
# ruby
mise use --global ruby@3.3.3
mise use --global node@20
mise use --global python@3.12
```

## Install Overmind

We use overmind to manage process in local development.
Follow the overmind project to install overmind.

```
# on macOS (with homebrew)
brew install tmux
brew install overmind
```

## Install nginx

Because we use rails and fastapi for different path, we need to set them in the same domain to void the cross domain problem, so we use nginx to direct requests.

```
brew install nginx
```

## Prepare to run

Maybe you need to execute different command to prepare the project.

```
# for webapp:
cd webapp
npm install

# for website
cd website
npm install

# for ruby on rails in api
cd api
gem install bundler
bundle install
bin/rails db:setup
bin/rails db:migrate

# for python
cd chat-api
poetry install

# install model for turn detector
poetry run python -m app.agent download-files
```

## Prepare Env file

Create .env file in the root dir using example ( or get one from @medal)

```
cp env.example .env
```

Then link it to sub-project:

```
cd api
ln -s ../.env .

cd chat-api
ln -s ../.env .
```

## Add hosts alias

using hosts.example file to add content to your /etc/hosts(need admin permission)

```
127.0.0.1       www.local.animos.cc
127.0.0.1       api.local.animos.cc
127.0.0.1       app.local.animos.cc
```

## Run

```
# start all process
overmind start

# stop
overmind stop
```

in Procfile, we have these process:

- nginx: cd deploy/nginx && nginx -p . -c ./nginx.conf -g "daemon off;"
- website: cd website && pnpm dev --port 9001
- webapp: cd webapp && npm run dev -- --port 9002
- api: cd api && rails server -p 9003
- chat-api: cd chat-api && poetry run uvicorn app.main:app --reload --port 9004
- api-docs: cd api-docs && npx serve -p 9005
- job: cd api && bundle exec rake solid_queue:start

# View our product

```
# website
http://www.local.animos.cc

# Web App
http://app.local.animos.cc

# Api
http://api.local.animos.cc

# api docs
http://api.local.animos.cc/api-docs
```
