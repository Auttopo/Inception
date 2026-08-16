# WordPress & PHP-FPM Microservice (`srcs/requirements/wordpress`)

This directory contains the build configuration for the WordPress web application and PHP 8.2 FastCGI Process Manager (FPM) container.

---

## 📌 Technical Summary

- **Base Image**: `debian:12.15`
- **Installed Packages**: `php8.2-fpm`, `php8.2-mysql`, `php8.2-redis`, `wordpress`, `curl`, and standard PHP extension suite (`cli`, `curl`, `xml`, `gd`, `zip`, `mbstring`, `intl`)
- **Listening Address**: `0.0.0.0:9000`
- **Target Volume Mount**: `/home/abenabde/data`

---

## 🛠️ Configuration Details

### 1. PHP-FPM Pool Configuration
In [`Dockerfile`](file:///home/user/Documents/Inception/srcs/requirements/wordpress/Dockerfile), the default Unix socket or loopback binding in `/etc/php/8.2/fpm/pool.d/www.conf` is reconfigured to listen on TCP port `9000`:
```sed
listen = 0.0.0.0:9000
```

### 2. Initialization Script Logic (`ENTRYPOINT`)
When the container initializes:
1. Checks for `/etc/wordpress/config-www.abenabde.42.fr.php`. If missing:
   - Auto-generates the WordPress PHP configuration with environment credentials:
     - `DB_NAME`: `$WP_DB_NAME`
     - `DB_USER`: `$WP_DB_USER`
     - `DB_PASSWORD`: `$WP_DB_PASSWORD`
     - `DB_HOST`: `mariadb:3306`
     - `WP_REDIS_HOST`: `redis`
     - `WP_REDIS_PORT`: `6379`
     - `WP_CACHE`: `true`
   - Validates PHP syntax via `php -l`.
   - Duplicates config for non-www alias (`config-abenabde.42.fr.php`).
   - Copies clean WordPress application files from `/usr/share/wordpress/*` into the shared volume mount directory `/home/abenabde/data/` (`cp -rn`).
2. Copies the local minimal [`object-cache.php`](file:///home/user/Documents/Inception/srcs/requirements/wordpress/object-cache.php) drop-in into `/home/abenabde/data/wp-content/object-cache.php` to enable instant, offline WP core Redis caching.
3. Prepares runtime environment for PHP-FPM using `systemd-tmpfiles`.
4. Launches PHP-FPM in foreground mode: `exec /usr/sbin/php-fpm8.2 -F`.

---

## 🔑 Required Environment Variables

| Variable Name | Source | Description |
| :--- | :--- | :--- |
| `WP_DB_NAME` | `.env` | Database name on `mariadb:3306` |
| `WP_DB_USER` | `.env` | Database user account |
| `WP_DB_PASSWORD` | `.env` | Password for database user |
