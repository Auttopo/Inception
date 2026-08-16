FROM debian:12.15
RUN apt update && apt install -y vsftpd && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/run/vsftpd/empty
COPY vsftpd.conf /etc/vsftpd.conf
CMD sh -c '\
useradd -m "$FTP_USER" 2>/dev/null && echo "$FTP_USER:$FTP_PASSWORD" | chpasswd; \
chown -R "$FTP_USER:$FTP_USER" /home/abenabde/data; \
exec vsftpd /etc/vsftpd.conf \
'
