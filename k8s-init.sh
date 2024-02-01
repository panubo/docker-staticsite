#!/usr/bin/env bash

# This script will copy the nginx config and html content to /volume then run
# the normal renderers. This is used in an initContainer in a Kubernetes pod.
# The /volume mount should then be mounted into the main container as
# readOnly mounts and using `k8s-nginx` as the command.

K8S_VOLUME_PATH="${K8S_VOLUME_PATH:=/volume}"

source /panubo-functions.sh

set -euo pipefail
IFS=$'\n\t'

[[ "${DEBUG:-}" == 'true' ]] && set -x

mkdir "${K8S_VOLUME_PATH}/config"
mkdir "${K8S_VOLUME_PATH}/content"

cp -a /etc/nginx/http.d "${K8S_VOLUME_PATH}/config"
cp -a "${NGINX_SERVER_ROOT}" "${K8S_VOLUME_PATH}/content"

(
  export OLD_NGINX_SERVER_ROOT="${NGINX_SERVER_ROOT}"
  export NGINX_SERVER_ROOT=${K8S_VOLUME_PATH}/content/html
  /templater.sh
)

render_templates "${K8S_VOLUME_PATH}/config/http.d/default.conf.tmpl"
