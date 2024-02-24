#!/bin/bash

if [ -z "$1" ]; then
  echo "./personalize.sh <username>"
  exit 1
fi

find . -type f -name '*.yaml' -exec sed -E -i '' s#https://github.com/[-_a-zA-Z0-9]+#https://github.com/${1}#g {} +
find . -type f -name '*.yaml' -exec sed -E -i '' s#ghcr.io/[-_a-zA-Z0-9]+#ghcr.io/${1}#g {} +
