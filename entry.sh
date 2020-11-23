#!/usr/bin/env bash

source /panubo-functions.sh

set -e

[[ "${DEBUG:-}" == 'true' ]] && set -x

# Defaults
export NGINX_SERVER_ROOT=${NGINX_SERVER_ROOT:='/var/www/html'}
export NGINX_SERVER_INDEX=${NGINX_SERVER_INDEX:='index.html index.htm'}

echo "> Running templater"
/templater.sh

echo "> Entrypoint command:" "${@}"

if [[ "${1}" == "s3sync" ]]; then
  /s3sync.sh
elif [[ "${1}" == "nginx" ]]; then
  render_templates /etc/nginx/conf.d/default.conf.tmpl
  echo "> Running nginx"
  nginx
else
  exec "${@}"
fi
