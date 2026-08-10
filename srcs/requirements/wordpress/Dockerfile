FROM debian:12.15
WORKDIR /app/wordpress
LABEL description="WordPress"

RUN apt update
RUN apt install -y php php8.2-fpm php8.2-cli php8.2-mysql php8.2-curl php8.2-xml php8.2-gd php8.2-zip php8.2-mbstring php8.2-intl wordpress curl
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf
RUN echo '\n\
<?php\n\
\n\
define('DB_NAME', 'wordpress');\n\
define('DB_USER', 'wordpress');\n\
define('DB_PASSWORD', 'password');\n\
define('DB_HOST', 'mariadb:3306');\n\
define('DB_CHARSET', 'utf8');\n\
define('DB_COLLATE', '');\n\
' > /etc/wordpress/config-www.abenabde.42.fr.php

RUN php -l /etc/wordpress/config-www.abenabde.42.fr.php

ENTRYPOINT cp -rn /usr/share/wordpress/* /home/abenabde/data/ && service php8.2-fpm start && sleep infinity

# CMD ["sudo systemctl status php8.2-fpm --no-pager"]
