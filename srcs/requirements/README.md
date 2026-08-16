# Requirements Ecosystem (`srcs/requirements`)

This directory houses the individual container definitions for each service required by the project. Every service is isolated in its own subdirectory and built from a clean `debian:12.15` minimal base image.

---

## 📦 Microservices Matrix (Active & Expansion Nodes)

| Service | Directory | Base Image | Core Software Stack | Internal Communication | Primary Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Nginx** | [`nginx/`](file:///home/user/Documents/Inception/srcs/requirements/nginx) | `debian:12.15` | Nginx, OpenSSL, TLS 1.3 | Port 443 (HTTPS) | Reverse Proxy & SSL Termination |
| **WordPress** | [`wordpress/`](file:///home/user/Documents/Inception/srcs/requirements/wordpress) | `debian:12.15` | WordPress, PHP 8.2, PHP-FPM, `php-redis` | Port 9000 (FastCGI) | Dynamic Web Application |
| **MariaDB** | [`mariadb/`](file:///home/user/Documents/Inception/srcs/requirements/mariadb) | `debian:12.15` | MariaDB Server | Port 3306 (MySQL) | Relational SQL Storage |
| **Redis** | [`redis/`](file:///home/user/Documents/Inception/srcs/requirements/redis) *(Phase 1)* | `debian:12.15` | Redis Server | Port 6379 (Redis) | In-Memory Object Cache for WP |
| **FTP** | [`ftp/`](file:///home/user/Documents/Inception/srcs/requirements/ftp) *(Phase 2)* | `debian:12.15` | vsftpd | Ports 21, 30000-30009 | FTP File Management for `wp-data` |
| **Adminer** | `adminer/` *(Phase 3)* | `debian:12.15` | Single-file PHP Adminer, PHP CLI Server | Port 8080 (HTTP) | Web Database GUI for MariaDB |

---

## 📐 General Microservice Design Rules

1. **Base OS Compliance**: Every `Dockerfile` inherits strictly from `FROM debian:12.15`.
2. **Minimal Configuration Principle**: Avoid any unused lines, packages, or build layers. Only keep minimal functioning code.
3. **Foreground Daemon Execution**:
   - Nginx: `nginx -g 'daemon off;'`
   - WordPress (PHP-FPM): `php-fpm8.2 -F`
   - MariaDB: `mysqld_safe --datadir=/home/abenabde/data`
   - Redis: `redis-server --protected-mode no --bind 0.0.0.0`
   - FTP: `vsftpd /etc/vsftpd.conf`
   - Adminer: `php -S 0.0.0.0:8080 -t /var/www/html`
4. **Automated Initialization**: Services perform self-initialization on first run if data directories or configuration files are absent.
5. **Data Isolation & Volume Sharing**: Application data and database files are persisted to volume mounts pointing to `/home/abenabde/data/`.
