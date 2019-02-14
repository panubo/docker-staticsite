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
    echo "Error: AWS_ACCESS_KEY not specified"
    exit 128
  fi

  if [ -z "$AWS_SECRET_KEY" ]; then
      echo "Error: AWS_SECRET_KEY not specified"
      exit 128
  fi

  # run the command
  s3cmd --access_key=${AWS_ACCESS_KEY} --secret_key=${AWS_SECRET_KEY} sync /var/www/html s3://${AWS_BUCKET_NAME}
}

echo "Running $@..."

if [ "${1}" == "s3sync" ]; then
  s3sync
else
  exec "$@"
fi
