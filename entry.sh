#!/usr/bin/env bash

source /panubo-functions.sh

set -e

[[ "${DEBUG:-}" == 'true' ]] && set -x

# Defaults
export NGINX_SERVER_ROOT=${NGINX_SERVER_ROOT:='/var/www/html'}
export NGINX_SERVER_INDEX=${NGINX_SERVER_INDEX:='index.html index.htm'}
export NGINX_SINGLE_PAGE_ENABLED=${NGINX_SINGLE_PAGE_ENABLED:='false'}
export NGINX_SINGLE_PAGE_INDEX=${NGINX_SINGLE_PAGE_INDEX:-'index.html'}
export DEPLOYFILE_PRE=${DEPLOYFILE_PRE:-'/Deployfile.pre'}
export DEPLOYFILE_POST=${DEPLOYFILE_POST:-'/Deployfile.post'}

templater() {
  echo "> Running templater"
  /templater.sh
}

deployfile_pre() {
  if [[ -f "${DEPLOYFILE_PRE}" ]] && [[ "${RUN_DEPLOYFILE_COMMANDS:-}" == 'true' ]]; then
    echo "> Running all commands in ${DEPLOYFILE_PRE}"
    run_all "${DEPLOYFILE_PRE}"
  fi
}

echo "> Entrypoint command:" "${@}"

if [[ "${1}" == "s3sync" ]]; then
  templater
  deployfile_pre
  echo "> Running s3sync"
  /s3sync.sh
  if [[ -f "${DEPLOYFILE_POST}" ]] && [[ "${RUN_DEPLOYFILE_COMMANDS:-}" == 'true' ]]; then
    echo "> Running all commands in ${DEPLOYFILE_POST}"
    run_all "${DEPLOYFILE_POST}"
  fi
elif [[ "${1}" == "nginx" ]]; then
  templater
  deployfile_pre
  echo "> Running nginx"
  render_templates /etc/nginx/http.d/default.conf.tmpl
  nginx
elif [[ "${1}" == "k8s-nginx" ]]; then
  echo "> Running nginx"
  nginx
elif [[ "${1}" == "k8s-init" ]]; then
  echo "> Running Kubernetes template script"
  /k8s-init.sh
  exit
else
  if [[ "$1" != "" ]]; then
    exec "${@}"
  else
    echo "No command specified."
    exit 127
  fi
fi
