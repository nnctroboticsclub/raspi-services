#!/bin/bash -e
. .env

file=$1
group=$2

if [ -z "$file" ]; then
  echo "Usage: $0 <file> <group>"
  exit 1
fi

if [ ! -f "$file" ]; then
  echo "File not found!"
  exit 1
fi

if [ -z "$group" ]; then
  echo "Usage: $0 <file> <group>"
  exit 1
fi

# POST the file to $server/api/deb/upload
curl --progress-bar -X POST "$server/api/deb/upload?group=$group" -F "file=@$file"
