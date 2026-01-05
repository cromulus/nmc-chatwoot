#!/bin/sh
set -e

# Validate required environment variables
if [ -z "$CHATWOOT_ROLE" ]; then
  echo "ERROR: CHATWOOT_ROLE environment variable is required"
  echo "Valid values: 'rails' or 'sidekiq'"
  exit 1
fi

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL environment variable is required"
  exit 1
fi

if [ -z "$REDIS_URL" ]; then
  echo "ERROR: REDIS_URL environment variable is required"
  exit 1
fi

# Execute based on role
case "$CHATWOOT_ROLE" in
  rails)
    echo "Starting Chatwoot Rails server..."
    echo "Running database migrations..."
    bundle exec rails db:chatwoot_prepare

    # Use the original entrypoint then start Rails
    exec docker/entrypoints/rails.sh bundle exec rails s -p 3000 -b 0.0.0.0
    ;;
  sidekiq)
    echo "Starting Chatwoot Sidekiq worker..."

    # Use the original entrypoint then start Sidekiq
    exec docker/entrypoints/rails.sh bundle exec sidekiq -C config/sidekiq.yml
    ;;
  *)
    echo "ERROR: Invalid CHATWOOT_ROLE: '$CHATWOOT_ROLE'"
    echo "Valid values: 'rails' or 'sidekiq'"
    exit 1
    ;;
esac
