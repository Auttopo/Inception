# Docker Compose Orchestration Layer (`srcs`)

This directory contains the central Docker Compose configuration and environment definitions required to build, network, and manage the containerized infrastructure.

---

## 📄 File Manifest

| File | Role & Purpose |
| :--- | :--- |
| [`docker-compose.yml`](file:///home/user/Documents/Inception/srcs/docker-compose.yml) | Multi-container composition defining services, volumes, networks, and environment bindings. |
| `.env` | Environment file containing secret keys and credentials (created automatically during `make install`). |
| `.dockerignore` | Defines pattern exclusions to prevent unnecessary build context transfers. |
| [`requirements/`](file:///home/user/Documents/Inception/srcs/requirements) | Subfolder housing individual Dockerfiles and runtime scripts for each service. |

---

## ⚙️ Service Specifications

### 1. `nginx`
- **Build Context**: `requirements/nginx`
- **Exposed Ports**: `443` (HTTPS)
- **Networks**: `net_front`, `net_nginx_adminer`
- **Volume Mounts**: `wp-data` mapped to `/home/abenabde/data` to read WordPress PHP static files.
- **Routing**: Proxies `/adminer` requests to `adminer:8080` over `net_nginx_adminer`.
- **Restart Policy**: `unless-stopped`

### 2. `wordpress`
- **Build Context**: `requirements/wordpress`
- **Hostname**: `www.abenabde.42.fr`
- **Networks**: `net_front`, `net_wp_db`, `net_wp_cache`
- **Environment Variables**:
  - `WP_DB_NAME`: Database name (`${WP_DB_NAME}`)
  - `WP_DB_USER`: Database user (`${WP_DB_USER}`)
  - `WP_DB_PASSWORD`: Database password (`${WP_DB_PASSWORD}`)
- **Volume Mounts**: `wp-data` mapped to `/home/abenabde/data` for core WordPress installation files.
- **Restart Policy**: `unless-stopped`

### 3. `mariadb`
- **Build Context**: `requirements/mariadb`
- **Networks**: `bridge_2` (Private internal network only; isolated from external ingress)
- **Environment Variables**:
  - `MYSQL_DATABASE`: Database name (`${WP_DB_NAME}`)
  - `MYSQL_USER`: Database user (`${WP_DB_USER}`)
  - `MYSQL_PASSWORD`: User password (`${WP_DB_PASSWORD}`)
  - `MYSQL_ROOT_PASSWORD`: Root password (`${DB_ROOT_PASSWORD}`)
- **Volume Mounts**: `db-data` mapped to `/home/abenabde/data` for persistent database storage.
- **Restart Policy**: `unless-stopped`

### 4. `redis`
- **Build Context**: `requirements/redis`
- **Networks**: `net_wp_cache` (Dedicated caching network shared with WordPress)
- **Restart Policy**: `unless-stopped`

### 5. `ftp`
- **Build Context**: `requirements/ftp`
- **Exposed Ports**: `21` (Control), `30000-30009` (Passive data)
- **Networks**: `net_front`
- **Environment Variables**:
  - `FTP_USER`: FTP user (`${FTP_USER}`)
  - `FTP_PASSWORD`: FTP password (`${FTP_PASSWORD}`)
- **Volume Mounts**: `wp-data` mapped to `/home/abenabde/data` for direct WordPress file access.
- **Restart Policy**: `unless-stopped`

### 6. `adminer`
- **Build Context**: `requirements/adminer`
- **Networks**: `net_nginx_adminer` (receives proxied requests from Nginx), `net_adminer_db` (connects to MariaDB)
- **Access**: `https://abenabde.42.fr/adminer` — routed by Nginx, no direct host port exposure.
- **Restart Policy**: `unless-stopped`

---

## 🌐 Network Topology

```
+--------------------------------------------------------------------------------------------+
|                                         HOST                                               |
|                                                                                            |
|      Port 443 (HTTPS)                           Port 21 / 30000-30009 (FTP)               |
|           │                                                │                               |
|           ▼                                                ▼                               |
|   +--------------------+    net_front     +--------------------+                          |
|   |       nginx        |<───────────────> |        ftp         |                          |
|   |   (net_front,      |                  |    (net_front)     |                          |
|   |  net_nginx_adminer)|                  +--------------------+                          |
|   +--------------------+                              │ (shared wp-data volume)            |
|       │            │                                  ▼                                    |
|       │(net_front) │(net_nginx_adminer)   +--------------------+                          |
|       ▼            ▼                      |     wordpress      |                          |
|  +----------+  +----------+               | (net_front,        |                          |
|  |wordpress |  | adminer  |               |  net_wp_db,        |                          |
|  |(net_front|  |(net_nginx |               |  net_wp_cache)     |                          |
|  | net_wp_db|  | _adminer, |               +--------------------+                          |
|  | net_wp_  |  | net_admin |                  │               │                            |
|  | cache)   |  | er_db)   |                   │(net_wp_cache) │(net_wp_db)                 |
|  +----------+  +----------+                   ▼               ▼                            |
|       │              │                  +--------+      +-----------+                      |
|       │(net_wp_db)   │(net_adminer_db)  | redis  |      |  mariadb  |                      |
|       ▼              └─────────────────>|(net_wp |      |(net_wp_db,|                      |
|  +----------+                           | cache) |      |net_adminer|                      |
|  | mariadb  |<──────────────────────────+--------+      |_db)       |                      |
|  |(net_wp_db|                                           +-----------+                      |
|  | net_adm  |                                                                              |
|  | iner_db) |                                                                              |
|  +----------+                                                                              |
+--------------------------------------------------------------------------------------------+

Access path: https://abenabde.42.fr/adminer → nginx → (net_nginx_adminer) → adminer → (net_adminer_db) → mariadb
```

---

## 💾 Storage Volume Mechanics

Docker Compose defines two custom `local` volumes using host bind mounts:
1. `wp-data`:
   - Host path: `/home/abenabde/data/wp_data`
   - Container target: `/home/abenabde/data` (in `nginx` & `wordpress` containers)
2. `db-data`:
   - Host path: `/home/abenabde/data/db_data`
   - Container target: `/home/abenabde/data` (in `mariadb` container)

Both directory targets on the host machine are ensured and generated by running `make install`.
