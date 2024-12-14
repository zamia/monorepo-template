nginx: cd deploy/nginx && nginx -p . -c ./nginx.conf -g "daemon off;"
api: cd api && bundle install && bundle exec rails db:migrate && bundle exec rails server -p 9101
jobs: cd api && bin/jobs
webapp: cd webapp && pnpm install && pnpm build && pnpm dev --port 9002
api-docs: cd api-docs && npx serve -p 9003
agent: cd agent && poetry install && poetry run python -m app.agent dev
chat-api: cd chat-api && poetry install && poetry run python -m app.server --port 9004