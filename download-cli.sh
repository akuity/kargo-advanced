#!/bin/bash

if [ -z "$1" ]; then
  echo "./download-cli.sh /usr/local/bin/kargo"
  exit 1
fi

version=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/akuity/kargo/releases/latest))
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)
download_url=https://github.com/akuity/kargo/releases/download/${version}/kargo-${os}-${arch}

curl -L -o ${1} ${download_url}
chmod +x ${1}
