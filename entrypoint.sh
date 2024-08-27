#!/bin/bash
set -e

rm -f /myapp/tmp/pids/server.pid

# production環境の場合のみ
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rails assets:precompile
  # 本番環境（AWS ECS）への初回デプロイ時に利用
  # 初回デプロイ後にコメントアウト
  #bundle exec rails db:create

  # シード作成後にコメントアウト
  bundle exec rails db:seed

  # マイグレーション処理
  bundle exec rails db:migrate
fi

exec "$@"
