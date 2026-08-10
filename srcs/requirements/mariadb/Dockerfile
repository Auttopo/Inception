FROM debian:12.15
WORKDIR /app/mariadb
LABEL description="MariaDB Server"
EXPOSE 3306

RUN apt update
# RUN apt install -y wget lsb-release gnupg
# RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.36-1_all.deb
# RUN DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.36-1_all.deb
# RUN apt update
RUN apt install -y mariadb-server galera-4

RUN service mariadb start

ENTRYPOINT service mariadb start &&  mariadb-secure-installation && sleep infinity


#HEALTHCHECK --start-period=5m \
#	CMD mariadb -e 'SELECT @@datadir;' || exit 1


