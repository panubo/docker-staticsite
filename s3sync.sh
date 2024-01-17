#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

[[ "${DEBUG:-}" == 'true' ]] && set -x

CACHE_CONTROL_DEFAULT="${CACHE_CONTROL_DEFAULT-public, max-age=3600}"
CACHE_CONTROL_DEFAULT_OVERRIDE="${CACHE_CONTROL_DEFAULT_OVERRIDE-public, max-age=60, s-maxage=60}"

s3sync() {
  # Update the modified time on all files
  # This ensures we always upload the desired content with the sync command
  # We still need to use `sync` since it supports the `--delete` parameter
  find "${NGINX_SERVER_ROOT}" -type f -exec touch {} \;

  AWS=( "aws" "--debug" )
  # Support AWS_ENDPOINT_OVERRIDE to allow use with non AWS S3 endpoints
  if [[ -n "${AWS_ENDPOINT_OVERRIDE:-}" ]]; then
    AWS+=( "--endpoint-url" "${AWS_ENDPOINT_OVERRIDE}" )
  fi

  # Configuration checks
  if [[ -z "${AWS_BUCKET_NAME:-}" ]]; then
    echo "Error: AWS_BUCKET_NAME is not specified"
    exit 128
  fi

  if [[ -z "${AWS_ACCESS_KEY_ID:-}" ]]; then
    echo "Warning: AWS_ACCESS_KEY_ID not specified"
  fi

  if [[ -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
    echo "Warning: AWS_SECRET_ACCESS_KEY not specified"
  fi

  CMD=()
  OVERRIDE_CMD=("--exclude" '*')

  # Add --dryrun if DEBUG=true
  if [[ "${DEBUG:-}" == "true" ]]; then
    CMD+=("--dryrun")
    OVERRIDE_CMD+=("--dryrun")
  fi

  # Add the Cache Control default if set
  if [[ -n "${CACHE_CONTROL_DEFAULT}" ]]; then
    CMD+=("--cache-control" "${CACHE_CONTROL_DEFAULT}")
  fi

  # Add exclude when an override is set
  while read -r line; do
    # value="$(
    #   export "${line?}"
    #   name="${line%%\=*}"
    #   echo "${!name}"
    # )"
    # IFS=":" read -r -a override <<<"${value}"
    IFS=":" read -r -a override <<<"${line#*\=}"
    CMD+=("--exclude" "${override[0]}")
    echo ">> Adding exclude for: ${override[0]}"
  done < <(env | grep -E "^(CACHE_CONTROL_OVERRIDE|CONTENT_TYPE_OVERRIDE)")

  # Run the main sync (excludes overrides)
  set -x
  "${AWS[@]}" s3 sync "${NGINX_SERVER_ROOT}" "s3://${AWS_BUCKET_NAME}" --delete "${CMD[@]}" --no-progress
  set +x

  # Run the override syncs
  while read -r line; do
    IFS=":" read -r -a override <<<"${line#*\=}"
    echo ">> Cache-control override sync for: ${override[0]}"
    cache_control="${override[1]:-${CACHE_CONTROL_DEFAULT_OVERRIDE}}"
    set -x
    "${AWS[@]}" s3 sync "${NGINX_SERVER_ROOT}" "s3://${AWS_BUCKET_NAME}" --delete "${OVERRIDE_CMD[@]}" --include "${override[0]}" --cache-control "${cache_control}" --no-progress
    set +x
  done < <(env | grep "^CACHE_CONTROL_OVERRIDE")

  while read -r line; do
    IFS=":" read -r -a override <<<"${line#*\=}"
    echo ">> Content-type override sync for: ${override[0]}"
    content_type="${override[1]}"
    set -x
    "${AWS[@]}" s3 sync "${NGINX_SERVER_ROOT}" "s3://${AWS_BUCKET_NAME}" --delete "${OVERRIDE_CMD[@]}" --include "${override[0]}" --content-type "${content_type}" --no-progress
    set +x
  done < <(env | grep "^CONTENT_TYPE_OVERRIDE")

}

s3sync
echo ">> Sync done"
