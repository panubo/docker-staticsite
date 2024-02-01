#!/usr/bin/env bash

source /panubo-functions.sh

set -euo pipefail
IFS=$'\n\t'

[[ "${DEBUG:-}" == 'true' ]] && set -x

# render templates when set
while read -r line; do
  newline="${line#*\=}"
  echo ">> Running templater on ${newline}"
  (
    # relative paths to server root
    cd "${NGINX_SERVER_ROOT}"
    # render templates and replace any full paths if OLD_NGINX_SERVER_ROOT is set (set by k8s-init.sh)
    render_templates "${newline/${OLD_NGINX_SERVER_ROOT:-}/${NGINX_SERVER_ROOT}}"
  )
done < <(env | grep "^RENDER_TEMPLATE")
