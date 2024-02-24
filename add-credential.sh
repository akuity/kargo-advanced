#!/bin/bash

set -e

repo=$(grep "url:" github-creds.yaml | awk '{print $2}')

echo "Configuring credentials for $repo"
echo -n "Username: "
read username
echo -n "Password: "
read -s password

tempfile="$(mktemp)"
trap "rm -f ${tempfile}" EXIT

cat ./github-creds.yaml | sed -E "s/username: .*/username: $username/" | sed -E "s/password: .*/password: $password/" > $tempfile

kargo apply -f $tempfile
