FROM debian:12.15
WORKDIR /app/mariadb
LABEL description="MariaDB Server"

RUN apt update
RUN apt install -y mariadb-server

RUN sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
RUN sed -i "s|^datadir.*|datadir = /home/abenabde/data|" /etc/mysql/mariadb.conf.d/50-server.cnf

RUN sed -i "s|/var/lib/mysql|/home/abenabde/data|g" /etc/apparmor.d/usr.sbin.mysqld 2>/dev/null || true

ENTRYPOINT sh -c ' \
    chown -R mysql:mysql /home/abenabde/data; \
    if [ ! -d /home/abenabde/data/mysql ]; then \
        mysql_install_db --user=mysql --datadir=/home/abenabde/data ; \
        mysqld_safe --datadir=/home/abenabde/data --skip-networking & \
        until mysqladmin ping 2>/dev/null; do sleep 1; done; \
        mysql -u root -e " \
            ALTER USER \"root\"@\"localhost\" IDENTIFIED BY \"$MYSQL_ROOT_PASSWORD\"; \
            CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`; \
            CREATE USER IF NOT EXISTS \"$MYSQL_USER\"@\"%\" IDENTIFIED BY \"$MYSQL_PASSWORD\"; \
            GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO \"$MYSQL_USER\"@\"%\"; \
            FLUSH PRIVILEGES;"; \
        mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown; \
    fi; \
    exec mysqld_safe --datadir=/home/abenabde/data'
