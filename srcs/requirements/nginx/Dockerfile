FROM debian:12.15
WORKDIR /app/nginx
LABEL description="Nginx interface"

RUN apt update
RUN apt install -y nginx openssl
RUN mkdir -p /etc/nginx/cert
RUN openssl req -x509 -newkey rsa:2048 -keyout /etc/nginx/cert/wordpress.key -out /etc/nginx/cert/wordpress.crt -days 365 -nodes -subj "/CN=abenabde.42.fr"
RUN openssl req -x509 -newkey rsa:2048 -keyout /etc/nginx/cert/pizza.key -out /etc/nginx/cert/pizza.crt -days 365 -nodes -subj "/CN=abenabde.pizza.fr"
COPY static-site.html /home/abenabde/static_website/static-site.html

RUN echo '\n\
\n\
server{\n\
	listen 443 ssl;\n\
	ssl_certificate /etc/nginx/cert/pizza.crt;\n\
	ssl_certificate_key /etc/nginx/cert/pizza.key;\n\
	ssl_protocols TLSv1.3;\n\
\n\
	server_name www.abenabde.pizza.fr abenabde.pizza.fr;\n\
	root /home/abenabde/static_website;\n\
	index index.html;\n\
\n\
	location / {\n\
		try_files static-site.html;\n\
	}\n\
}\n\
server {\n\
	listen 443 ssl;\n\
	ssl_certificate /etc/nginx/cert/wordpress.crt;\n\
	ssl_certificate_key /etc/nginx/cert/wordpress.key;\n\
	ssl_protocols TLSv1.3;\n\
\n\
	server_name www.abenabde.42.fr abenabde.42.fr;\n\
	root /home/abenabde/data;\n\
	index index.php index.html;\n\
\n\
	location /adminer {\n\
		proxy_pass http://adminer:8080;\n\
		proxy_set_header Host $host;\n\
		proxy_set_header X-Real-IP $remote_addr;\n\
	}\n\
\n\
	location / {\n\
		try_files $uri $uri/ /index.php$is_args$args;\n\
	}\n\
\n\
	location ~ \.php$ {\n\
		fastcgi_pass wordpress:9000;\n\
		fastcgi_index index.php;\n\
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;\n\
		include fastcgi_params;\n\
	}\n\
}\n\
' >> /etc/nginx/conf.d/serversconfig.conf

ENTRYPOINT ["sh", "-c", "nginx -t && nginx -g 'daemon off;'"]
