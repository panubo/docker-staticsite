#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

function s3sync() {
  # Configuration checks
  if [ -z "$AWS_BUCKET_NAME" ]; then
    echo "Error: AWS_BUCKET_NAME is not specified"
    exit 128
  fi

  if [ -z "$AWS_ACCESS_KEY" ]; then
    echo "Warning: AWS_ACCESS_KEY not specified"
  fi

  if [ -z "$AWS_SECRET_KEY" ]; then
    echo "Warning: AWS_SECRET_KEY not specified"
  fi

  # run the command
  aws s3 sync /var/www/html s3://${AWS_BUCKET_NAME} --delete
}

echo "Running $@..."

if [ "${1}" == "s3sync" ]; then
  s3sync
else
  exec "$@"
fi
