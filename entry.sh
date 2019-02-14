#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

echo "Running $@..."
exec "$@"
