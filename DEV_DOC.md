# DEV_DOC.md — Inception Developer Documentation

## 1. Project Overview

**Inception** is a Docker Compose infrastructure project. Every service is built
from scratch using `debian:12.15` as the base image — no pre-built application images
are used. The stack is managed entirely via a `Makefile` at the repository root.

### Repository layout

```
Inception/
├── Makefile                    ← Build, run, and lifecycle commands
├── USER_DOC.md                 ← End-user documentation
├── DEV_DOC.md                  ← This file
└── srcs/
    ├── docker-compose.yml      ← Service orchestration
    ├── .env                    ← Secrets (auto-generated, not committed)
    ├── .dockerignore
    ├── requirements/           ← Mandatory services
    │   ├── nginx/              ← Reverse proxy (TLS 1.3, port 443)
    │   ├── wordpress/          ← PHP-FPM 8.2 CMS
    │   └── mariadb/            ← MariaDB relational database
    └── bonus/                  ← Bonus services
        ├── redis/              ← Redis object cache
        ├── ftp/                ← vsftpd FTP server
        ├── adminer/            ← Adminer DB web GUI
        └── game/               ← Multiplayer game (SSE/WebSocket)
```

---

## 2. Environment Setup (from scratch)

### Prerequisites

- A Linux host with `sudo` privileges.
- `make` installed.
- Internet access for `apt` package downloads during image builds.

### Step 1 — Run the installer

```bash
make install
```

This single command performs all provisioning:

1. **Installs Docker** by running `docker_install.sh`.
2. **Registers domain names** in `/etc/hosts`:
   ```
   127.0.0.1 abenabde.42.fr www.abenabde.42.fr
   127.0.0.1 abenabde.pizza.fr www.abenabde.pizza.fr
   127.0.0.1 abenabde.game.fr www.abenabde.game.fr
   ```
3. **Creates host data directories**:
   ```
   /home/abenabde/data/wp_data/       ← WordPress + Nginx files
   /home/abenabde/data/db_data/       ← MariaDB database files
   /home/abenabde/data/static_website/ ← Static site files
   ```
4. **Generates `srcs/.env`** with random 80-character hex secrets via `openssl rand -hex 40`.

### Step 2 — Verify the `.env` file

```bash
cat srcs/.env
```

Expected format:

```env
WP_DB_NAME=wordpressnetwork
WP_DB_USER=wordpressuser
WP_DB_PASSWORD=<80-char hex>
DB_ROOT_PASSWORD=<80-char hex>
FTP_USER=ftpuser
FTP_PASSWORD=<80-char hex>
```

> **Never commit this file.** It is excluded by `.gitignore`.

---

## 3. Build and Launch

### Build images and start all services

```bash
make run
```

Internally runs:
```bash
cd srcs && sudo docker compose build && sudo docker compose up -d --remove-orphans
```

All images are built locally; Docker Hub is not used.

### Makefile targets reference

| Target | Action |
| :--- | :--- |
| `make install` | Installs Docker, sets up host, generates `.env` |
| `make run` | Builds images and starts all containers (detached) |
| `make stop` | Stops containers (preserves data) |
| `make status` | Lists running containers (`docker ps`) |
| `make clean` | Removes containers, volumes, and builder cache |
| `make fclean` | Removes containers, volumes, **all images**, and builder cache |

---

## 4. Container and Volume Management

### Useful Docker commands

```bash
# View logs for a specific service
sudo docker logs <service_name>
# Examples:
sudo docker logs nginx
sudo docker logs wordpress
sudo docker logs mariadb

# Open a shell inside a running container
sudo docker exec -it <service_name> bash

# Inspect a specific volume
sudo docker volume inspect srcs_wp-data
sudo docker volume inspect srcs_db-data

# Force rebuild a single service without cache
cd srcs && sudo docker compose build --no-cache <service_name>

# Restart a single service
cd srcs && sudo docker compose restart <service_name>
```

### Network topology

```
HOST
 │
 ├── Port 443 (HTTPS) ──────────────────────────► nginx
 ├── Port 21, 30000-30009 (FTP) ─────────────────► ftp
 │
 │  [net_front]          nginx ◄──────────────► wordpress
 │                       nginx ◄──────────────► ftp
 │
 │  [net_wp_db]          wordpress ◄──────────► mariadb (port 3306)
 │
 │  [net_wp_cache]       wordpress ◄──────────► redis (port 6379)
 │
 │  [net_nginx_adminer]  nginx ◄──────────────► adminer (port 8080)
 │
 │  [net_adminer_db]     adminer ◄────────────► mariadb (port 3306)
 │
 │  [net_game_stream]    nginx ◄──────────────► game (port 8042)
```

---

## 5. Data Persistence

All stateful data lives on the **host filesystem** via volumes:

| Volume name | Host path | Mounted in | Purpose |
| :--- | :--- | :--- | :--- |
| `wp-data` | `/home/abenabde/data/wp_data` | `nginx`, `wordpress`, `ftp` | WordPress application files |
| `db-data` | `/home/abenabde/data/db_data` | `mariadb` | MariaDB database files |
| `static-website` | `/home/abenabde/data/static_website` | `nginx` | Static site HTML files |

Data survives `make stop` and `make run` cycles. It is permanently deleted only by
`make clean` or `make fclean` (which run `docker compose down -v`).

### First-run initialization

- **MariaDB**: On first start, if `/home/abenabde/data/db_data/mysql` does not exist,
  `mysql_install_db` runs and the WordPress database/user are created automatically from `.env`.
- **WordPress**: On first start, if the config file is absent, `wp-config.php` equivalents are
  generated from `.env` variables, and WordPress core files are copied into the shared volume.

---

## 6. TEST — Service Validation

Run `make run` and `make status` first to confirm all containers are `Up` before testing.

---

### 6.1 The websites are accessible and functional.

| Site | URL |
| Main website (WordPress) | [www.abenabde.42.fr](https://www.abenabde.42.fr) |
| Adminer | [www.abenabde.42.fr/adminer](https://www.abenabde.42.fr/adminer)  |
| Pizza website | [www.abenabde.pizza.fr](https://www.abenabde.pizza.fr) |
| Game website | [www.abenabde.game.fr](https://www.abenabde.game.fr) |

---

### 6.2 WordPress Usages

**What to test:** WordPress config is generated: PHP-FPM is running, Redis extension is loaded, MariaDB is functioning.

```bash
# Test 1 — PHP-FPM process is running inside the container
sudo docker exec -it $(sudo docker ps -qf "name=wordpress") ps aux | grep php-fpm
# Expected: php-fpm8.2 processes listed

# Test 2 — PHP Redis extension is loaded
sudo docker exec -it $(sudo docker ps -qf "name=wordpress") \
    php -m | grep redis
# Expected: redis

# Test 3 — MariaDB process is running
sudo docker exec -it $(sudo docker ps -qf "name=mariadb") \
    mysqladmin -u root -p"$(grep DB_ROOT_PASSWORD srcs/.env | cut -d= -f2)" ping
# Expected: mysqld is alive

# Test 4 — WordPress database exists
sudo docker exec -it $(sudo docker ps -qf "name=mariadb") \
    mysql -u root -p"$(grep DB_ROOT_PASSWORD srcs/.env | cut -d= -f2)" \
    -e "SHOW DATABASES;" | grep wordpressnetwork
# Expected: wordpressnetwork
```

---

### 6.3 Redis

**What to test:** Server is responsive, WordPress can connect via the Redis PHP extension.

```bash
# Test 1 — Redis responds to PING
sudo docker exec -it $(sudo docker ps -qf "name=redis") redis-cli ping
# Expected: PONG

# Test 2 — Memory configuration is applied
sudo docker exec -it $(sudo docker ps -qf "name=redis") \
    redis-cli config get maxmemory
# Expected: 268435456 (256 MB)

# Test 3 — WordPress can connect to Redis over the internal network
sudo docker exec -it $(sudo docker ps -qf "name=wordpress") \
    php -r '$r = new Redis(); $r->connect("redis", 6379); echo $r->ping() . "\n";'
# Expected: 1

# Test 4 — Write and read a key (end-to-end cache test)
sudo docker exec -it $(sudo docker ps -qf "name=redis") \
    redis-cli set test_key "inception_ok"
sudo docker exec -it $(sudo docker ps -qf "name=redis") \
    redis-cli get test_key
# Expected: inception_ok
```

---

### 6.4 FTP

**What to test:** FTP server accepts authentication, can list files, upload works and is visible in the shared volume.

```bash
# Load credentials from .env
FTP_USER=$(grep ^FTP_USER srcs/.env | cut -d= -f2)
FTP_PASS=$(grep ^FTP_PASSWORD srcs/.env | cut -d= -f2)

# Test 1 — List remote directory
curl -u "$FTP_USER:$FTP_PASS" ftp://localhost:21/
# Expected: directory listing of /home/abenabde/data

# Test 2 — Upload a test file via FTP
echo "Inception FTP test" > /tmp/ftp_test.txt
curl -u "$FTP_USER:$FTP_PASS" -T /tmp/ftp_test.txt ftp://localhost:21/ftp_test.txt
# Expected: 226 Transfer complete (no error)

# Test 3 — Verify the uploaded file is visible in the shared WordPress volume
sudo docker exec -it $(sudo docker ps -qf "name=wordpress") \
    cat /home/abenabde/data/ftp_test.txt
# Expected: Inception FTP test

# Test 4 — Clean up the test file
curl -u "$FTP_USER:$FTP_PASS" -Q "DELE ftp_test.txt" ftp://localhost:21/
```
