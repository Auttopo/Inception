# Redis Microservice (`srcs/requirements/redis`)

This directory contains the build configuration for the Redis in-memory cache container.

---

## 📌 Technical Summary

- **Base Image**: `debian:12.15`
- **Installed Package**: `redis-server`
- **Exposed Port**: `6379` (Internal container network `bridge_3` only)
- **Memory Management**: `maxmemory 256mb`, `allkeys-lru` eviction policy

---

## 🛠️ Configuration & Runtime

### 1. Minimal Dockerfile (`Dockerfile`)
- Builds directly from `debian:12.15`.
- Installs `redis-server` package with apt cache cleanup (`rm -rf /var/lib/apt/lists/*`).
- `CMD` executes Redis in un-protected mode for containerized bridge communication:
  ```bash
  CMD ["redis-server", "--protected-mode", "no", "--bind", "0.0.0.0", "--maxmemory", "256mb", "--maxmemory-policy", "allkeys-lru"]
  ```

### 2. Integration with WordPress
- WordPress connects over `bridge_3` via hostname `redis:6379`.
- WordPress utilizes the `php8.2-redis` PHP extension.
- Configuration constants defined in `/etc/wordpress/config-www.abenabde.42.fr.php`:
  ```php
  define('WP_REDIS_HOST', 'redis');
  define('WP_REDIS_PORT', 6379);
  define('WP_CACHE', true);
  ```

---

## 🧪 Verification Commands

```bash
# 1. Verify Redis process inside container
docker exec -it redis redis-cli ping
# Expected output: PONG

# 2. Check memory stats
docker exec -it redis redis-cli info memory

# 3. Test connectivity from WordPress container
docker exec -it wordpress php -r '$r = new Redis(); $r->connect("redis", 6379); echo $r->ping();'
# Expected output: +PONG
```
