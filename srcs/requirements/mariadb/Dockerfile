FROM debian:12.15
WORKDIR /app/mariadb
LABEL description="MariaDB Server"

RUN apt update
RUN apt install -y mariadb-server

RUN sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

ENTRYPOINT sh -c ' \
mkdir -p /var/lib/mysql /run/mysqld; \
chown -R mysql:mysql /var/lib/mysql /run/mysqld; \
if [ ! -f /var/lib/mysql/.mysql_init ]; then \
    mysql_install_db --user=mysql --datadir=/var/lib/mysql; \
    mysqld_safe --datadir=/var/lib/mysql --skip-networking & \
    until mysqladmin ping --silent 2>/dev/null; do sleep 1; done; \
    mysql -u root -e " \
        ALTER USER \"root\"@\"localhost\" IDENTIFIED BY \"$MYSQL_ROOT_PASSWORD\"; \
        CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`; \
        CREATE USER IF NOT EXISTS \"$MYSQL_USER\"@\"%\" IDENTIFIED BY \"$MYSQL_PASSWORD\"; \
        GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO \"$MYSQL_USER\"@\"%\"; \
        FLUSH PRIVILEGES;"; \
    mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown; \
    touch /var/lib/mysql/.mysql_init; \
fi; \
exec mysqld_safe --datadir=/var/lib/mysql'
