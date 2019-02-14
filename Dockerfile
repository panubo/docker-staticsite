FROM docker.io/alpine:3.9

ENV S3CMD_VERSION=2.0.2

RUN apk update \
  && apk add --no-cache bash git nginx py-pip \
  && pip install s3cmd==${S3CMD_VERSION} \
  && mkdir -p /run/nginx /var/www/html

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf

COPY entry.sh /entry.sh

ENTRYPOINT ["/entry.sh"]

EXPOSE 80
STOPSIGNAL SIGTERM

CMD ["nginx"]
