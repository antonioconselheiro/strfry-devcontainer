FROM ubuntu:jammy AS host
ENV DEBIAN_FRONTEND=noninteractive
FROM ubuntu:jammy AS build
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /build

RUN apt update
RUN apt install -y --no-install-recommends \
    git g++ make pkg-config libtool ca-certificates \
    libssl-dev zlib1g-dev liblmdb-dev libflatbuffers-dev \
    libsecp256k1-dev libzstd-dev

# Clean
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/hoytech/strfry
WORKDIR /build/strfry

RUN git submodule update --init
RUN make setup-golpe
RUN make -j4

FROM host
VOLUME /db
VOLUME /log

# copy relay from build container
COPY --from=build /build/strfry /usr/local/bin
COPY ./strfry.conf /etc/strfry.conf

# Install dev tools and relay dependencies
RUN apt update
RUN apt install -y --no-install-recommends curl git jq nginx openssh-client liblmdb0 libflatbuffers1 libsecp256k1-0 libb2-1 libzstd1

# Installing nak, the nostr army knife
RUN curl -k -L -o nak-v0.7.7-linux-amd64 https://github.com/fiatjaf/nak/releases/download/v0.7.7/nak-v0.7.7-linux-amd64
RUN mv nak-v0.7.7-linux-amd64 /usr/bin/nak
RUN chmod +x /usr/bin/nak

# Clean
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

# Credentials
COPY ./.gitconfig /root/.gitconfig
COPY ./.ssh /root/.ssh
RUN chmod 600 -R /root/.ssh
RUN ssh-add -D && ssh-add /root/.ssh/id_ed25519 || true

# config nginx
RUN rm -rf /etc/nginx/sites-available/default
RUN mkdir -p /etc/nginx/sites-available
RUN echo 'server {\n\
  server_name localhost;\n\
  location / {\n\
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\
      proxy_set_header Host $host;\n\
      proxy_pass http://0.0.0.0:7777;\n\
      proxy_http_version 1.1;\n\
      proxy_set_header Upgrade $http_upgrade;\n\
      proxy_set_header Connection "upgrade";\n\
  }\n\
}' > /etc/nginx/sites-available/default

ENV LANG C.UTF-8
ENV TZ America/Sao_Paulo

EXPOSE 7777
WORKDIR /strfry-dev
COPY start.sh .
COPY log.sh .

ENTRYPOINT [ "sh", "./start.sh" ]