#!/usr/bin/env bash

set -e

[[ "${DEBUG:-}" == 'true' ]] && set -x

echo "Running" "${@}"

if [[ "${1}" == "s3sync" ]]; then
  /s3sync.sh
elif [[ "${1}" == "templater" ]]; then
  /templater.sh
else
  exec "${@}"
fi
