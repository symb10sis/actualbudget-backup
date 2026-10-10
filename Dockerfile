# syntax=docker/dockerfile:1

FROM rclone/rclone:sha-9ee9d0a

LABEL "repository"="https://github.com/rodriguestiago0/actual-backup" \
  "homepage"="https://github.com/rodriguestiago0/actual-backup"

ENV LOCALTIME_FILE="/tmp/localtime"
ENV HOME="/tmp"
ENV npm_config_cache="/tmp/.npm"
ENV NODE_PATH="/app/node_modules"

COPY scripts/*.js /app/
COPY scripts/*.sh /app/

RUN apk add --no-cache grep file bash supercronic curl jq zip 7zip nodejs npm wget tar xz tzdata \
  && ln -sf "${LOCALTIME_FILE}" /etc/localtime \
  && mkdir -p /app/node_modules /config /backup /tmp \
  && cd /app && npm install "@actual-app/api@latest" \
  && chmod -R 777 /app /config /backup /tmp \
  && chmod +x /app/*.sh

ENTRYPOINT ["/app/entrypoint.sh"]
