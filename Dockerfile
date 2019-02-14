FROM docker.io/alpine:3.9


RUN apk update \
  && apk add bash git nginx \
  && mkdir -p /run/nginx /var/www/html \
  && rm -rf /var/cache/apk/*

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf

COPY entry.sh /entry.sh

ENTRYPOINT ["/entry.sh"]

EXPOSE 80
STOPSIGNAL SIGTERM

CMD ["nginx"]
