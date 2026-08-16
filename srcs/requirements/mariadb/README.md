# MariaDB Microservice (`srcs/requirements/mariadb`)

This directory contains the build configuration for the MariaDB relational database container.

---

## 📌 Technical Summary

- **Base Image**: `debian:12.15`
- **Installed Package**: `mariadb-server`
- **Data Directory**: `/home/abenabde/data`
- **Bound Network Address**: `0.0.0.0`
- **Listening Port**: `3306` (Internal container network `bridge_2` only)

---

## 🛠️ Configuration Details

### 1. [`Dockerfile`](file:///home/user/Documents/Inception/srcs/requirements/mariadb/Dockerfile) Blueprint
- Replaces default `bind-address` with `0.0.0.0` in `/etc/mysql/mariadb.conf.d/50-server.cnf` to allow internal container connections from the `wordpress` service.
- Redirects default MySQL data directory from `/var/lib/mysql` to `/home/abenabde/data`.
- Patches AppArmor profile if present to permit mysqld operations on custom host mount path `/home/abenabde/data`.

### 2. Startup Entrypoint Script Logic
The container execution script (`ENTRYPOINT`) automates initial database creation idempotently:
1. Sets file ownership: `chown -R mysql:mysql /home/abenabde/data`.
2. Checks if `/home/abenabde/data/mysql` exists. If **not present**:
   - Runs `mysql_install_db --user=mysql --datadir=/home/abenabde/data`.
   - Starts temporary `mysqld_safe` in the background with networking skipped (`--skip-networking`).
   - Polls `mysqladmin ping` until the engine is ready.
   - Executes SQL initialization:
     - Sets `root` localhost password to `$MYSQL_ROOT_PASSWORD`.
     - Creates database `$MYSQL_DATABASE` (default: `wordpressnetwork`).
     - Creates user `$MYSQL_USER`@`%` (default: `wordpressuser`) with `$MYSQL_PASSWORD`.
     - Grants full database privileges to `$MYSQL_USER`.
     - Flushes privileges.
   - Shuts down the temporary background server.
3. Launches the primary foreground process: `exec mysqld_safe --datadir=/home/abenabde/data`.

---

## 🔑 Required Environment Variables

| Variable Name | Source | Description |
| :--- | :--- | :--- |
| `MYSQL_DATABASE` | `.env` (`WP_DB_NAME`) | Name of the database to create for WordPress |
| `MYSQL_USER` | `.env` (`WP_DB_USER`) | Username for WordPress database connections |
| `MYSQL_PASSWORD` | `.env` (`WP_DB_PASSWORD`) | Password for `MYSQL_USER` |
| `MYSQL_ROOT_PASSWORD` | `.env` (`DB_ROOT_PASSWORD`) | Root administrator password |
