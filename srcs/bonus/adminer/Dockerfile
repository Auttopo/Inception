FROM debian:12.15
RUN apt update && apt install -y adminer php-cli php-mysql && rm -rf /var/lib/apt/lists/*
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/usr/share/adminer/adminer"]
