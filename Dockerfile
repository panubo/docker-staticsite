FROM docker.io/panubo/awscli:1.18.170

ENV GOMPLATE_VERSION=3.8.0
ENV GOMPLATE_CHECKSUM=13b39916b11638b65f954fab10815e146bad3a615f14ba2025a375faf0d1107e

RUN set -x \
  && cd /tmp \
  && wget -nv https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-amd64 \
  && echo "${GOMPLATE_CHECKSUM}  gomplate_linux-amd64" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum gomplate_linux-amd64)"; exit 1; )) \
  && chmod +x gomplate_linux-amd64 \
  && mv gomplate_linux-amd64 /usr/local/bin/gomplate \
  && rm -rf /tmp/* \
  ;

# Install Panubo Bash Container functions
RUN set -x \
  && BASHCONTAINER_VERSION=0.6.0 \
  && if [ -n "$(readlink /usr/bin/wget)" ]; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && if ! command -v gpg > /dev/null; then \
      fetchDeps="${fetchDeps} gnupg"; \
     fi \
  && apk add --no-cache ca-certificates bash curl coreutils ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz.asc \
  && GPG_KEYS="E51A4070A3FFBD68C65DDB9D8BECEF8DFFCC60DD" \
  && ( gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$GPG_KEYS" \
      || gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
      || gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$GPG_KEYS" ) \
  && gpg --batch --verify panubo-functions.tar.gz.asc panubo-functions.tar.gz  \
  && tar -C / -zxf panubo-functions.tar.gz \
  && rm -rf /tmp/* \
  && apk del ${fetchDeps} \
  ;

RUN apk update \
  && apk add --no-cache bash git nginx \
  && mkdir -p /run/nginx /var/www/html

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY default.conf.tmpl /etc/nginx/conf.d/default.conf.tmpl

COPY *.sh /

ENTRYPOINT ["/entry.sh"]

EXPOSE 80
STOPSIGNAL SIGTERM

CMD ["nginx"]
