#!/bin/bash

if [ -z "$1" ]
  then
    echo "./personalize.sh <username>"
    exit 1
fi

find . -type f -name '*.yaml' -exec sed -i '' s#https://github.com/akuity#https://github.com/${1}#g {} +
find . -type f -name '*.yaml' -exec sed -i '' s#ghcr.io/akuity#ghcr.io/${1}#g {} +
