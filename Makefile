

all:
	cd srcs ;\
	sudo docker compose build ;\
	sudo docker compose up -d

install:
	sudo echo "127.0.0.1 abenabde.42.fr www.abenabde.42.fr" >> /etc/hosts

stop:
	cd srcs ;\
	sudo docker compose stop
	
status:
	sudo docker ps
