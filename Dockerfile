# Unified Chatwoot Dockerfile for Rails and Sidekiq roles
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

FROM chatwoot/chatwoot:v4.9.1-ce

# Install curl for healthchecks
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

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
