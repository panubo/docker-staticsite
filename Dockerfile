FROM docker.io/panubo/awscli:1.19.16

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
  && BASHCONTAINER_VERSION=0.7.1 \
  && BASHCONTAINER_SHA256=e13b1930e75aa4c5526820b5c7ec4f3530bdcfda45752bcf8dfef193d4624977 \
  && if [ -n "$(readlink /usr/bin/wget)" ]; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && apk add --no-cache ca-certificates bash curl coreutils ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz \
  && echo "${BASHCONTAINER_SHA256}  panubo-functions.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum panubo-functions.tar.gz)"; exit 1; )) \
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
