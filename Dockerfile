FROM alpine:3.19

# Install bash-container functions
RUN set -x \
  && BASHCONTAINER_VERSION=0.8.0 \
  && BASHCONTAINER_SHA256=0ddc93b11fd8d6ac67f6aefbe4ba790550fc98444e051e461330f10371a877f1 \
  && if [ -n "$(readlink /usr/bin/wget)" ]; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && apk add --no-cache ca-certificates bash curl coreutils ${fetchDeps} \
  && cd /tmp \
  && wget -nv https://github.com/panubo/bash-container/releases/download/v${BASHCONTAINER_VERSION}/panubo-functions.tar.gz \
  && echo "${BASHCONTAINER_SHA256}  panubo-functions.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum panubo-functions.tar.gz)"; exit 1; )) \
  && tar --no-same-owner -C / -zxf panubo-functions.tar.gz \
  && rm -rf /tmp/* \
  && apk del ${fetchDeps} \
  ;

# Install gomplate
RUN set -x \
  && GOMPLATE_VERSION=v3.11.6 \
  && GOMPLATE_CHECKSUM_X86_64=7ce8f9f89a0b21fac05b8412af4dd8a06f9e5d8a2df70370549d2dde5f9f0d75 \
  && GOMPLATE_CHECKSUM_AARCH64=f41b6cfaebd9c744c3091993baf9ca44cd80e07d63143d2e78457a159fc22dc5 \
  && if [ "$(uname -m)" = "x86_64" ] ; then \
        GOMPLATE_CHECKSUM="${GOMPLATE_CHECKSUM_X86_64}"; \
        GOMPLATE_ARCH="amd64"; \
      elif [ "$(uname -m)" = "aarch64" ]; then \
        GOMPLATE_CHECKSUM="${GOMPLATE_CHECKSUM_AARCH64}"; \
        GOMPLATE_ARCH="arm64"; \
      fi \
  && curl -sSf -o /tmp/gomplate_linux-${GOMPLATE_ARCH} -L https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-${GOMPLATE_ARCH} \
  && echo "${GOMPLATE_CHECKSUM}  gomplate_linux-${GOMPLATE_ARCH}" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum gomplate_linux-${GOMPLATE_ARCH})"; exit 1; )) \
  && install -m 0755 /tmp/gomplate_linux-${GOMPLATE_ARCH} /usr/local/bin/gomplate \
  && rm -f /tmp/* \
  ;

RUN apk update \
  && apk add --no-cache bash tree git nginx aws-cli \
  && cd /etc/nginx \
  && mkdir -p /run/nginx /var/www/html \
  && ln -s /dev/stdout /var/log/nginx/access.log \
  && ln -s /dev/stderr /var/log/nginx/error.log \
  && chown nginx:nginx /etc/nginx/http.d \
  && chown nginx:nginx /var/www/html \
  ;

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY default.conf.tmpl /etc/nginx/http.d/default.conf.tmpl

COPY *.sh /

ENTRYPOINT ["/entry.sh"]

EXPOSE 80
STOPSIGNAL SIGTERM

USER nginx

CMD ["nginx"]
