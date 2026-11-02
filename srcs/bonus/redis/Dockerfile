FROM debian:12.15
WORKDIR /app/redis
LABEL description="Redis Cache for WordPress"

RUN apt update && apt install -y redis-server && rm -rf /var/lib/apt/lists/*

EXPOSE 6379

CMD ["redis-server", "--protected-mode", "no", "--bind", "0.0.0.0", "--maxmemory", "256mb", "--maxmemory-policy", "allkeys-lru"]
