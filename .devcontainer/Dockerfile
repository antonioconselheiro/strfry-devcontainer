FROM nginx

RUN apt update
RUN apt install -y git build-essential libyaml-perl \
  libtemplate-perl libregexp-grammars-perl libssl-dev \
  zlib1g-dev liblmdb-dev libflatbuffers-dev libsecp256k1-dev \
  libzstd-dev certbot python3-certbot-nginx jq wget

# Install docker and docker-compose
RUN curl -sSL https://get.docker.com/ | sh
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# Installing nak, the nostr army knife
RUN wget https://github.com/fiatjaf/nak/releases/download/v0.7.7/nak-v0.7.7-linux-amd64
RUN mv nak-v0.7.7-linux-amd64 /usr/bin/nak
RUN chmod +x /usr/bin/nak

# Clean
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

COPY ./pool/strfry.conf /etc/strfry.conf

RUN git clone https://github.com/hoytech/strfry
WORKDIR /db
WORKDIR /strfry

RUN git submodule update --init
RUN make setup-golpe
RUN make -j4

RUN cp strfry /usr/local/bin
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

# Credentials
COPY ./.gitconfig /root/.gitconfig
COPY ./.ssh /root/.ssh
RUN chmod 600 -R /root/.ssh
RUN ssh-add -D && ssh-add /root/.ssh/id_ed25519 || true

EXPOSE 7777
WORKDIR /strfry-dev


ENTRYPOINT [ "sh", "/strfry-dev/pool/start.sh" ]