FROM docker.io/panubo/awscli:1.16.299

RUN apk update \
  && apk add --no-cache bash git nginx \
  && mkdir -p /run/nginx /var/www/html

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf

COPY entry.sh /entry.sh
COPY s3sync /s3sync

ENTRYPOINT ["/entry.sh"]

EXPOSE 80
STOPSIGNAL SIGTERM

CMD ["nginx"]
