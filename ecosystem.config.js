module.exports = {
  apps: [
    {
      name: "project-webapp",
      cwd: "webapp",
      interpreter: "none",
      script: "pnpm install && pnpm build && pnpm serve --listen 7002",
      args: "",
      env: {},
    },
    {
      name: "project-api",
      cwd: "api",
      interpreter: "none",
      script:
        "bundle install && bundle exec rails db:migrate && bundle exec rails server -p 7003",
      args: "",
      env: {
        RAILS_ENV: "production",
      },
    },
    {
      name: "project-agent",
      cwd: "agent",
      interpreter: "none",
      script: "poetry install && poetry run python -m app.agent start",
      args: "",
      env: {},
    },
    {
      name: "project-chat-api",
      cwd: "agent",
      interpreter: "none",
      script: "poetry install && poetry run python -m app.server --port 7004",
      args: "",
      env: {},
    },

    {
      name: "project-api-docs",
      cwd: "api-docs",
      interpreter: "none",
      script: "npx serve -p 7005",
      args: "",
      env: {},
    },
    {
      name: "project-job",
      cwd: "api",
      interpreter: "none",
      script: "bin/jobs",
      args: "",
      env: {
        RAILS_ENV: "production",
      },
    },
  ],
};
