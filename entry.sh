#!/usr/bin/env bash

set -e

[[ "${DEBUG:-}" == 'true' ]] && set -x

# Defaults
export NGINX_SERVER_ROOT=${NGINX_SERVER_ROOT:='/var/www/html'}
export NGINX_SERVER_INDEX=${NGINX_SERVER_INDEX:='index.html index.htm'}

echo "> Entrypoint command:" "${@}"

if [[ "${1}" == "s3sync" ]]; then
  /s3sync.sh
elif [[ "${1}" == "templater" ]]; then
  /templater.sh
elif [[ "${1}" == "nginx" ]]; then
  /templater.sh /etc/nginx/conf.d/default.conf.tmpl /etc/nginx/conf.d/default.conf
  echo "> Running nginx"
  nginx
else
  exec "${@}"
fi
