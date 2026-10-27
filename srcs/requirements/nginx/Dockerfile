FROM debian:12.15
WORKDIR /app/nginx
LABEL description="Nginx interface"

RUN apt update
RUN apt install -y nginx openssl

RUN mkdir -p /etc/nginx/cert
RUN openssl req -x509 -newkey rsa:2048 -keyout /etc/nginx/cert/wordpress.key -out /etc/nginx/cert/wordpress.crt -days 365 -nodes -subj "/CN=abenabde.42.fr"
RUN openssl req -x509 -newkey rsa:2048 -keyout /etc/nginx/cert/pizza.key -out /etc/nginx/cert/pizza.crt -days 365 -nodes -subj "/CN=abenabde.pizza.fr"
RUN openssl req -x509 -newkey rsa:2048 -keyout /etc/nginx/cert/game.key -out /etc/nginx/cert/game.crt -days 365 -nodes -subj "/CN=abenabde.game.fr"

RUN mkdir -p /game_data
COPY game_index.html /game_data/index.html
RUN chmod 777 /game_data/index.html

COPY static-site.html /home/abenabde/static_website/static-site.html
RUN chmod 777 /home/abenabde/static_website/static-site.html

COPY serversconfig.conf /etc/nginx/conf.d/serversconfig.conf

ENTRYPOINT ["sh", "-c", "nginx -t && nginx -g 'daemon off;'"]
