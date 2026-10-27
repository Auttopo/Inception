FROM debian:12.15
LABEL description="Game Run-Man server"

RUN apt update

RUN apt install -y zip git python3 pip pipx
RUN pipx install uv
ENV PATH=/root/.local/bin:$PATH

RUN git clone https://github.com/Auttopo/Inspired-by-pacman-game.git game
RUN cd game && make install && cd

ENTRYPOINT ["sh", "-c", "cd game; git pull; make"]
