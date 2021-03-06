#!/usr/bin/env bash

source /panubo-functions.sh

set -euo pipefail
IFS=$'\n\t'

[[ "${DEBUG:-}" == 'true' ]] && set -x

# render templates when set
while read -r line; do
  echo ">> Running templater on ${line#*\=}"
  (
    # relative paths to server root
    cd "${NGINX_SERVER_ROOT}"
    render_templates "${line#*\=}"
  )
done < <(env | grep "^RENDER_TEMPLATE")
