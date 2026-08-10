FROM debian:12.15
WORKDIR /app/wordpress
LABEL description="WordPress"
EXPOSE 9000

RUN apt update
RUN apt install -y php8.2-fpm php8.2-cli php8.2-mysql php8.2-curl php8.2-xml php8.2-gd php8.2-zip php8.2-mbstring php8.2-intl wordpress curl

ENTRYPOINT cp -rn /usr/share/wordpress/* /home/abenabde/data/ && service php8.2-fpm start && sleep infinity

# CMD ["sudo systemctl status php8.2-fpm --no-pager"]
