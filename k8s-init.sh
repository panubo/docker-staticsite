#!/usr/bin/env bash

# This script will copy the nginx config and html content to /volume then run
# the normal renderers. This is used in an initContainer in a Kubernetes pod.
# The /volume mount should then be mounted into the main container as
# readOnly mounts and using `k8s-nginx` as the command.

source /panubo-functions.sh

set -euo pipefail
IFS=$'\n\t'

[[ "${DEBUG:-}" == 'true' ]] && set -x

ls -la /

mkdir /volume/config
mkdir /volume/content

cp -a /etc/nginx/http.d /volume/config
cp -a "${NGINX_SERVER_ROOT}" /volume/content

export OLD_NGINX_SERVER_ROOT="${NGINX_SERVER_ROOT}"
export NGINX_SERVER_ROOT=/volume/content/html
/templater.sh

render_templates /volume/config/http.d/default.conf.tmpl
