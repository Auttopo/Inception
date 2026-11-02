FROM debian:12.15
WORKDIR /app/wordpress
LABEL description="WordPress"

RUN apt update
RUN apt install -y php php8.2-fpm php8.2-cli php8.2-mysql php8.2-curl php8.2-xml php8.2-gd php8.2-zip php8.2-mbstring php8.2-intl php8.2-redis wordpress curl
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

COPY object-cache.php /etc/wordpress/object-cache.php

ENTRYPOINT sh -c ' \
if [ ! -f /etc/wordpress/config-www.abenabde.42.fr.php ]; then \
	echo "<?php \
	define(\"DB_NAME\", \"$WP_DB_NAME\"); \
	define(\"DB_USER\", \"$WP_DB_USER\"); \
	define(\"DB_PASSWORD\", \"$WP_DB_PASSWORD\"); \
	define(\"DB_HOST\", \"mariadb:3306\"); \
	define(\"DB_CHARSET\", \"utf8\"); \
	define(\"DB_COLLATE\", \"\"); \
	define(\"WP_REDIS_HOST\", \"redis\"); \
	define(\"WP_REDIS_PORT\", 6379); \
	define(\"WP_CACHE\", true); \
	define(\"WP_DEBUG\", true); \
	define(\"WP_DEBUG_LOG\", \"/home/abenabde/data/wp-content/debug.log\"); \
	define(\"WP_DEBUG_DISPLAY\", false); \
	@ini_set(\"display_errors\", 0); \
	" > /etc/wordpress/config-www.abenabde.42.fr.php; \
	\
	php -l /etc/wordpress/config-www.abenabde.42.fr.php; \
	cp /etc/wordpress/config-www.abenabde.42.fr.php /etc/wordpress/config-abenabde.42.fr.php; \
	cp -rn /usr/share/wordpress/* /home/abenabde/data/; \
fi; \
mkdir -p /home/abenabde/data/wp-content; \
cp -f /etc/wordpress/object-cache.php /home/abenabde/data/wp-content/object-cache.php; \
systemd-tmpfiles --remove --create /usr/lib/tmpfiles.d/php8.2-fpm.conf; \
exec /usr/sbin/php-fpm8.2 -F; \
'
