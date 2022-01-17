#!/usr/bin/env bash

source /panubo-functions.sh

set -e

[[ "${DEBUG:-}" == 'true' ]] && set -x

# Defaults
export NGINX_SERVER_ROOT=${NGINX_SERVER_ROOT:='/var/www/html'}
export NGINX_SERVER_INDEX=${NGINX_SERVER_INDEX:='index.html index.htm'}
export NGINX_SINGLE_PAGE_ENABLED=${NGINX_SINGLE_PAGE_ENABLED:='false'}
export NGINX_SINGLE_PAGE_INDEX=${NGINX_SINGLE_PAGE_INDEX:-'index.html'}
export PROCFILE=${PROCFILE:-'/Procfile'}

echo "> Running templater"
/templater.sh

echo "> Entrypoint command:" "${@}"

if [[ -f "${PROCFILE}" ]] && [[ "${RUN_PROCFILE_COMMANDS:-}" == 'true' ]]; then
  echo ">> Running all commands in Procfile"
  run_all "${PROCFILE}"
fi

if [[ "${1}" == "s3sync" ]]; then
  echo "> Running s3sync"
  /s3sync.sh
elif [[ "${1}" == "nginx" ]]; then
  echo "> Running nginx"
  render_templates /etc/nginx/conf.d/default.conf.tmpl
  nginx
else
  if [[ "$1" != "" ]]; then
    exec "${@}"
  else
    echo "No command specified."
    exit 127
  fi
fi
