#!/usr/bin/env bash

set -e

[[ "${DEBUG:-}" == 'true' ]] && set -x

echo "Running " "${@}"

if [[ "${1}" == "s3sync" ]]; then
  /s3sync
else
  exec "${@}"
fi
