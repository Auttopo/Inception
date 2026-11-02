# USER_DOC.md — Inception User Documentation

## 1. Services Overview

The Inception stack runs six containerized services, all built from `debian:12.15`.

| Service | Purpose | Access |
| :--- | :--- | :--- |
| **Nginx** | HTTPS reverse proxy and TLS 1.3 termination | Port `443` (exposed to host) |
| **WordPress** | PHP 8.2 CMS web application (PHP-FPM) | Via Nginx at `https://abenabde.42.fr` |
| **MariaDB** | Relational SQL database (WordPress storage) | Internal only (port `3306`) |
| **Redis** | In-memory object cache for WordPress | Internal only (port `6379`) |
| **FTP** | vsftpd file transfer server (WordPress files) | Ports `21` and `30000–30009` |
| **Adminer** | Web-based database management GUI | Via Nginx at `https://abenabde.42.fr/adminer` |

> **Note:** Two additional virtual hosts are served by Nginx:
> - `https://abenabde.pizza.fr` — Static website
> - `https://abenabde.game.fr` — game bonus service

---

## 2. Start and Stop the Project

### First-time setup (run once)

Before starting the project for the first time, install Docker and provision the host environment:

```bash
make install
```

This command:
- Installs Docker on the host machine.
- Adds the required domain names to `/etc/hosts` (`abenabde.42.fr`, `abenabde.pizza.fr`, `abenabde.game.fr`).
- Creates the persistent data directories at `/home/abenabde/data/`.
- Generates a fresh `srcs/.env` file with random cryptographic passwords.

### Start the stack

```bash
make run
```

Builds all Docker images and starts every service in detached mode.

### Stop the stack

```bash
make stop
```

Stops all running containers without removing them or their data.

### Full cleanup

```bash
# Remove containers and volumes (data is lost):
make clean

# Remove containers, volumes, and all built images:
make fclean
```

---

## 3. Accessing the Services

> **Important:** All HTTPS connections use a **self-signed TLS certificate**. Your browser will display a security warning — this is expected. Accept the exception to proceed.

| URL | Description |
| :--- | :--- |
| `https://abenabde.42.fr` | WordPress website |
| `https://www.abenabde.42.fr` | WordPress website (www alias) |
| `https://abenabde.42.fr/adminer` | Adminer — database administration panel |
| `https://abenabde.pizza.fr` | Static website |
| `https://abenabde.game.fr` | Game service |

### Adminer login

Navigate to `https://abenabde.42.fr/adminer` and fill in the login form:

| Field | Value |
| :--- | :--- |
| **System** | MySQL |
| **Server** | `mariadb` |
| **Username** | *(value of `WP_DB_USER` in `srcs/.env`)* |
| **Password** | *(value of `WP_DB_PASSWORD` in `srcs/.env`)* |
| **Database** | *(value of `WP_DB_NAME` in `srcs/.env`)* |

### FTP access

Connect with any FTP client or `curl`:

```bash
# List files in the WordPress data directory
curl -u <FTP_USER>:<FTP_PASSWORD> ftp://abenabde.42.fr:21/
```

The FTP root maps directly to the WordPress shared file volume.

---

## 4. Credentials

All secrets are stored in a single file: **`srcs/.env`**

```
srcs/.env
├── WP_DB_NAME        — WordPress database name
├── WP_DB_USER        — WordPress database user
├── WP_DB_PASSWORD    — WordPress database password (random, 80 hex chars)
├── DB_ROOT_PASSWORD  — MariaDB root administrator password (random, 80 hex chars)
├── FTP_USER          — FTP login username
└── FTP_PASSWORD      — FTP login password (random, 80 hex chars)
```

> **Caution:** The `srcs/.env` file contains sensitive credentials. It is listed in `.gitignore` and must **never** be committed to version control. Each `make install` run regenerates it with fresh random values.

**To display current credentials:**

```bash
cat srcs/.env
```

---

## 5. Checking That Services Are Running

### View all running containers

```bash
make status
```

All six services should appear with status `Up`.

### Expected output (example)

```
CONTAINER ID   IMAGE              COMMAND     STATUS          PORTS
xxxxxxxxxxxx   srcs-nginx         ...         Up X minutes    0.0.0.0:443->443/tcp
xxxxxxxxxxxx   srcs-wordpress     ...         Up X minutes
xxxxxxxxxxxx   srcs-mariadb       ...         Up X minutes
xxxxxxxxxxxx   srcs-redis         ...         Up X minutes
xxxxxxxxxxxx   srcs-ftp           ...         Up X minutes    0.0.0.0:21->21/tcp
xxxxxxxxxxxx   srcs-adminer       ...         Up X minutes
```

### Quick connectivity checks

```bash
# WordPress site responds over HTTPS
curl -k -o /dev/null -s -w "%{http_code}\n" https://abenabde.42.fr
# Expected: 200 or 301

# Adminer panel responds through Nginx proxy
curl -k -o /dev/null -s -w "%{http_code}\n" https://abenabde.42.fr/adminer
# Expected: 200

# Redis is alive
sudo docker exec -it $(sudo docker ps -qf "name=redis") redis-cli ping
# Expected: PONG

# FTP server lists files
curl -u ftpuser:ftppassword ftp://localhost:21/
```
