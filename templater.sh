#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

[[ "${DEBUG:-}" == 'true' ]] && set -x

SOURCE="${1:-}"
DESTINATION="${2:-}"

# Configuration checks
if [[ -z "${SOURCE:-}" ]]; then
  echo "Error: SOURCE is not specified"
  exit 128
fi

if [[ -z "${DESTINATION:-}" ]]; then
  echo "Error: DESTINATION is not specified"
  exit 128
fi

echo ">> Running templater"
(set -x; gomplate --file "${SOURCE}" --out ${DESTINATION})

echo ">> Templater done"
