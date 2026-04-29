# Unified Chatwoot Dockerfile for Rails and Sidekiq roles
# Base image: Alpine Linux (use apk, not apt-get)
# Use CHATWOOT_ROLE environment variable to select: "rails" or "sidekiq"
#
# Required environment variables:
#   - CHATWOOT_ROLE: "rails" or "sidekiq"
#   - DATABASE_URL: PostgreSQL connection string
#   - REDIS_URL: Redis connection string
#
# Optional environment variables:
#   - RAILS_ENV: defaults to "production"
#   - NODE_ENV: defaults to "production"
#   - INSTALLATION_ENV: defaults to "docker"

FROM chatwoot/chatwoot:latest-ce

# Install curl for healthchecks
RUN apk add --no-cache curl

# Add Resend inbound email support until it is included in the upstream image.
RUN bundle config unset frozen || true && \
    bundle add actionmailbox-resend --version "~> 1.0" && \
    ruby -0pi -e 'unless $_.include?("ActionMailbox::Resend::Engine"); $_ = $_.sub(/Rails\.application\.routes\.draw do\n/, "Rails.application.routes.draw do\n  # Resend ActionMailbox ingress\n  mount ActionMailbox::Resend::Engine, at: %q{/rails/action_mailbox/resend}\n\n"); end' config/routes.rb

# Ensure entrypoint scripts are executable
RUN chmod +x docker/entrypoints/rails.sh

# Copy our role-based entrypoint alongside the original
COPY docker-entrypoint.sh docker/entrypoints/role.sh
RUN sed -i 's/\r$//' docker/entrypoints/role.sh && chmod +x docker/entrypoints/role.sh

# Set default environment
ENV RAILS_ENV=production \
    NODE_ENV=production \
    INSTALLATION_ENV=docker

EXPOSE 3000

ENTRYPOINT ["docker/entrypoints/role.sh"]
