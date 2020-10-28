FROM docker.io/panubo/awscli:1.18.155

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

RUN apk update \
  && apk add --no-cache bash git nginx \
  && mkdir -p /run/nginx /var/www/html

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf

COPY *.sh /

ENTRYPOINT ["/entry.sh"]

EXPOSE 80
STOPSIGNAL SIGTERM

CMD ["nginx"]
