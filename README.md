*This project has been created as part of the 42 curriculum by abenabde.*

# Inception

## Description

Inception is a system administration and DevOps project from the 42 curriculum.
The goal is to set up a small infrastructure composed of several services using
**Docker Compose**, where every container is built from scratch using `debian:12.15`
as the base image — no pre-built application images are allowed.

The mandatory stack includes:

- **Nginx** — HTTPS reverse proxy (TLS 1.3 only, port 443)
- **WordPress** — PHP 8.2 CMS served via PHP-FPM
- **MariaDB** — relational SQL database for WordPress

Bonus services extend the stack with:

- **Redis** — in-memory object cache for WordPress
- **FTP (vsftpd)** — file transfer access to the WordPress volume
- **Adminer** — web-based database management GUI, proxied by Nginx
- **Game** — a bonus multiplayer game served on its own virtual host

### Design choices

#### Virtual Machines vs Docker

| | Virtual Machines | Docker |
|---|---|---|
| Isolation | Full OS, own kernel | Shared kernel, process-level isolation |
| Resource usage | Heavy (GB of RAM per VM) | Lightweight (MB per container) |
| Startup time | Minutes | Seconds |
| Portability | `.vmdk` / `.ova` images | Portable `Dockerfile` + registry |

Docker was chosen because it provides sufficient isolation for this project with
far less overhead, and its declarative `Dockerfile` + Compose model makes the
infrastructure reproducible.

#### Secrets vs Environment Variables

Environment variables (stored in `srcs/.env`) are used for runtime configuration
such as database names, usernames, and passwords. They are injected into containers
at startup by Docker Compose and are never baked into the images.

Secrets (Docker Swarm secrets or external vaults) are a step further — they store
sensitive data outside the filesystem entirely and mount it as a read-only file
inside the container. For this project, `.env` variables are sufficient; the file
is excluded from version control via `.gitignore`.

#### Docker Network vs Host Network

Docker bridge networks (`bridge` driver) create isolated virtual networks.
Containers communicate by service name (DNS) and are invisible to the host
unless a port is explicitly published.

Host network mode (`--network host`) shares the host's network stack directly —
no isolation, no NAT. It is faster but removes all network segmentation.

This project uses multiple named bridge networks (`net_front`, `net_wp_db`,
`net_wp_cache`, etc.) to enforce the principle of least privilege: for example,
MariaDB is only reachable from containers on `net_wp_db`, never from Nginx.

#### Docker Volumes vs Bind Mounts

Bind mounts link a specific host path to a container, while Docker named volumes are managed by the Docker daemon and stored by default in `/var/lib/docker/volumes/` on Linux.

This project uses **Docker named volumes** for persistent storage, allowing Docker to manage the storage location independently of the containers. The `wp-data` and `db-data` volumes store website files and database data, respectively, and persist across container rebuilds. This approach simplifies storage management and helps keep persistent data separate from container lifecycles.

---

## Instructions

### 1. Prerequisites

- Linux host with `sudo` access
- `make` installed

### 2. First-time setup

```bash
make install
```

Installs Docker, registers domain names in `/etc/hosts`, creates data directories,
and generates `srcs/.env` with random credentials.

### 3. Build and start

```bash
make run
```

### 4. Other commands

```bash
make stop     # Stop all containers (data preserved)
make status   # List running containers
make clean    # Remove containers and volumes
make fclean   # Remove containers, volumes, and all images
```

### 5. Access

| URL | Service |
|---|---|
| `https://abenabde.42.fr` | WordPress |
| `https://abenabde.42.fr/adminer` | Adminer (DB GUI) |
| `https://abenabde.pizza.fr` | Static website |
| `https://abenabde.game.fr` | Game |

The browser will warn about a self-signed certificate — accept the exception.

> See **USER_DOC.md** for full user instructions and **DEV_DOC.md** for developer
> and testing details.

---

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [Nginx documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress Codex](https://codex.wordpress.org/)
- [vsftpd manual](https://security.appspot.com/vsftpd.html)
- [Redis documentation](https://redis.io/docs/)
- [Adminer project](https://www.adminer.org/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)

### AI usage

AI (Antigravity / Claude) was used during this project for:

- **Documentation writing** — generating and consolidating `README.md`,
  `USER_DOC.md`, and `DEV_DOC.md`.
- **Dockerfile and infrastructure review** — Using AI to understand minimal infrastructure configurations, web technologies (HTTP, streaming, protocols, etc.), and how the different components work together.
- **Code review** — Review of AI-generated code in languages I may not be familiar with (e.g., PHP, JavaScript), with all code supervised and verified by the author.
