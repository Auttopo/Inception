
all: run

run:
	cd srcs ;\
	sudo docker compose build ;\
	sudo docker compose up -d --remove-orphans

install:
	sudo ./docker_install.sh ;\
	sudo echo "127.0.0.1 abenabde.42.fr www.abenabde.42.fr" >> /etc/hosts ;\
	sudo echo "127.0.0.1 abenabde.pizza.fr www.abenabde.pizza.fr" >> /etc/hosts ;\
	sudo echo "127.0.0.1 abenabde.game.fr www.abenabde.game.fr" >> /etc/hosts ;\
	sudo mkdir -p /home/abenabde/data/wp_data ;\
	sudo mkdir -p /home/abenabde/data/db_data ;\
	sudo mkdir -p /home/abenabde/data/static_website ;\
\
	echo "WP_DB_NAME=wordpressnetwork\nWP_DB_USER=wordpressuser" > srcs/.env ;\
	echo -n "WP_DB_PASSWORD=" >> srcs/.env ;\
	openssl rand -hex 40 >> srcs/.env ;\
	echo -n "DB_ROOT_PASSWORD=" >> srcs/.env ;\
	openssl rand -hex 40 >> srcs/.env ;\
\
	echo -n "FTP_USER=" >> srcs/.env ;\
	echo "ftpuser" >> srcs/.env ;\
	echo -n "FTP_PASSWORD=" >> srcs/.env ;\
	openssl rand -hex 40 >> srcs/.env ;\
\
	sudo chmod 777 srcs/requirements/nginx/game_index.html ;\
	sudo chmod 777 srcs/requirements/nginx/static-site.html ;\
\

stop:
	cd srcs ;\
	sudo docker compose stop
	
status:
	sudo docker ps

clean:
	sudo docker rm $$(sudo docker ps -aq) ;\
	cd srcs ;\
	sudo docker compose stop ;\
	sudo docker compose down -v ;\
	sudo docker builder prune -f

fclean:
	cd srcs ;\
	sudo docker compose stop ;\
	sudo docker compose down -v --rmi all ;\
	sudo docker builder prune -a -f
	

.PHONY: all run install stop status fclean
