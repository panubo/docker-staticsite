FROM docker.io/alpine:3.9

ENV AWSCLI_VERSION=1.16.104

RUN apk update \
  && apk add --no-cache bash git nginx py-pip \
  && pip install awscli==${AWSCLI_VERSION} \
  && mkdir -p /run/nginx /var/www/html

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf

COPY entry.sh /entry.sh

ENTRYPOINT ["/entry.sh"]

EXPOSE 80
STOPSIGNAL SIGTERM

CMD ["nginx"]
