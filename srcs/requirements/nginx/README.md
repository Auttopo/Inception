# Nginx Microservice (`srcs/requirements/nginx`)

This directory contains the build configuration for the Nginx HTTPS reverse proxy and web server container.

---

## 📌 Technical Summary

- **Base Image**: `debian:12.15`
- **Installed Packages**: `nginx`, `openssl`
- **Exposed Port**: `443` (HTTPS)
- **Encryption Standard**: SSL / TLSv1.3 only
- **Certificate Path**: `/etc/nginx/cert/wordpress.crt`
- **Private Key Path**: `/etc/nginx/cert/wordpress.key`

---

## 🛠️ Configuration Details

### 1. SSL / TLS Certificate Generation
During image build ([`Dockerfile`](file:///home/user/Documents/Inception/srcs/requirements/nginx/Dockerfile)), OpenSSL generates a self-signed X.509 RSA-2048 certificate valid for 365 days:
```bash
openssl req -x509 -newkey rsa:2048 \
  -keyout /etc/nginx/cert/wordpress.key \
  -out /etc/nginx/cert/wordpress.crt \
  -days 365 -nodes -subj "/CN=abenabde.42.fr"
```

### 2. Nginx Virtual Host Configuration
Custom configuration is appended to `/etc/nginx/conf.d/wordpressconfig.conf`:
- **Port & SSL**: Listens on port `443 ssl` with `ssl_protocols TLSv1.3;`.
- **Server Name**: `www.abenabde.42.fr abenabde.42.fr`.
- **Document Root**: `/home/abenabde/data` (shared via `wp-data` volume).
- **FastCGI Proxying**: PHP requests (`~ \.php$`) are proxied to `wordpress:9000` via FastCGI protocol.
- **Adminer Proxying**: Requests to `/adminer` are proxied to `adminer:8080` over `net_nginx_adminer` network.

### 3. Networks
- `net_front`: Communication with WordPress (FastCGI) and FTP (shared volume).
- `net_nginx_adminer`: Isolated network dedicated to proxying requests to the Adminer container.

### 4. Build & Runtime Execution
- Validates configuration at build time using `nginx -t`.
- Starts Nginx in the foreground as the PID 1 container entrypoint: `nginx -g 'daemon off;'`.
