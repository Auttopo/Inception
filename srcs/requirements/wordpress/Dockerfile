FROM debian:12.15
WORKDIR /app/wordpress
LABEL description="WordPress"

RUN apt update
RUN apt install -y php php8.2-fpm php8.2-cli php8.2-mysql php8.2-curl php8.2-xml php8.2-gd php8.2-zip php8.2-mbstring php8.2-intl wordpress curl
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

ENTRYPOINT sh -c ' \
if [ ! -f /etc/wordpress/config-www.abenabde.42.fr.php ]; then \
	echo "<?php \
	define(\"DB_NAME\", \"$WP_DB_NAME\"); \
	define(\"DB_USER\", \"$WP_DB_USER\"); \
	define(\"DB_PASSWORD\", \"$WP_DB_PASSWORD\"); \
	define(\"DB_HOST\", \"mariadb:3306\"); \
	define(\"DB_CHARSET\", \"utf8\"); \
	define(\"DB_COLLATE\", \"\"); \
	" > /etc/wordpress/config-www.abenabde.42.fr.php; \
	\
	php -l /etc/wordpress/config-www.abenabde.42.fr.php; \
	cp /etc/wordpress/config-www.abenabde.42.fr.php /etc/wordpress/config-abenabde.42.fr.php; \
	cp -rn /usr/share/wordpress/* /home/abenabde/data/; \
fi; \
systemd-tmpfiles --remove --create /usr/lib/tmpfiles.d/php8.2-fpm.conf; \
exec /usr/sbin/php-fpm8.2 -F; \
'
