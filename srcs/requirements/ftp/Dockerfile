FROM debian:12.15
RUN apt update && apt install -y vsftpd && rm -rf /var/lib/apt/lists/*
COPY vsftpd.conf /etc/vsftpd.conf
EXPOSE 21 30000-30009
CMD sh -c '\
useradd -m "$FTP_USER" 2>/dev/null && echo "$FTP_USER:$FTP_PASSWORD" | chpasswd; \
chown -R "$FTP_USER:$FTP_USER" /home/abenabde/data; \
exec vsftpd /etc/vsftpd.conf \
'
