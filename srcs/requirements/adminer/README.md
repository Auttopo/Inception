# Adminer Microservice (`srcs/requirements/adminer`)

This directory contains the build configuration for the Adminer database management web application container.

---

## 📌 Technical Summary

- **Base Image**: `debian:12.15`
- **Installed Packages**: `adminer`, `php-cli`, `php-mysql` (all from official Debian APT)
- **Internal Port**: `8080` (not exposed to host — accessed via Nginx proxy only)
- **Networks**:
  - `net_nginx_adminer`: Receives proxied HTTP requests from Nginx
  - `net_adminer_db`: Connects to MariaDB on port `3306`
- **Access URL**: `https://abenabde.42.fr/adminer` (routed by Nginx TLS reverse proxy)

---

## 🔀 Access Path

```
Browser → https://abenabde.42.fr/adminer
  → Nginx (port 443, TLS 1.3)
    → proxy_pass http://adminer:8080 (net_nginx_adminer)
      → Adminer (PHP built-in server on :8080)
        → MariaDB:3306 (net_adminer_db)
```

---

## 🛠️ Configuration Details

### 1. Minimal Dockerfile (`Dockerfile`)
- Builds directly from `debian:12.15`.
- Installs Debian's official `adminer` package along with `php-cli` and `php-mysql` driver.
- Uses PHP's built-in web server to serve Adminer without requiring Apache or Nginx inside the container.
- The container has **no host port exposed** — isolation is guaranteed by network segmentation.

### 2. Nginx Proxy Configuration
Added to `requirements/nginx/Dockerfile`:
```nginx
location /adminer {
    proxy_pass http://adminer:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

---

## 🧪 Verification Commands

```bash
# 1. Rebuild and start all containers
make run

# 2. Check adminer container is Up
make status

# 3. Test internal reachability from nginx container
sudo docker exec -it $(sudo docker ps -qf "name=nginx") curl -s http://adminer:8080 | head -5

# 4. Test via HTTPS through Nginx (from host)
curl -k https://abenabde.42.fr/adminer

# 5. Open Adminer in browser
# URL: https://abenabde.42.fr/adminer
# System:   MySQL
# Server:   mariadb
# Username: wordpressuser
# Password: <WP_DB_PASSWORD from srcs/.env>
# Database: wordpressnetwork
```
