# FTP Microservice (`srcs/requirements/ftp`)

This directory contains the build configuration for the vsftpd FTP server container.

---

## 📌 Technical Summary

- **Base Image**: `debian:12.15`
- **Installed Package**: `vsftpd`
- **Exposed Ports**: `21` (Control), `30000-30009` (Passive Mode Data)
- **Target Volume**: Shared `wp-data` mount (`/home/abenabde/data`)
- **Default Account**: `ftpuser` / `ftppassword`

---

## 🛠️ Configuration Details

### 1. Minimal Configuration (`vsftpd.conf`)
- Disables anonymous access (`anonymous_enable=NO`).
- Enables local authentication & write capabilities (`local_enable=YES`, `write_enable=YES`).
- Restricts root directory to `/home/abenabde/data` (`local_root=/home/abenabde/data`).
- Configures passive port range (`30000-30009`).
- Disables seccomp sandboxing for container compatibility (`seccomp_sandbox=NO`).

### 2. Runtime Lifecycle
- Creates `/var/run/vsftpd/empty` (required secure chroot directory for vsftpd privilege separation).
- Creates local FTP user `$FTP_USER` with password `$FTP_PASSWORD` if missing.
- Sets ownership of `/home/abenabde/data` to `$FTP_USER`.
- Launches `/usr/sbin/vsftpd /etc/vsftpd.conf` in the foreground.

---

## 🧪 Verification Commands

```bash
# 1. Connect via FTP client or curl
curl -u ftpuser:ftppassword ftp://localhost:21/

# 2. Upload a test file via FTP
echo "FTP Test" > /tmp/test.txt
curl -u ftpuser:ftppassword -T /tmp/test.txt ftp://localhost:21/test.txt

# 3. Verify file exists in shared volume inside wordpress container
docker exec -it wordpress ls -la /home/abenabde/data/test.txt
```
