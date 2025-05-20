#!/bin/bash -e

server="https://robo-rpi.tail39b6e.ts.net/"
file=$1

if [ -z "$file" ]; then
  echo "Usage: $0 <file>"
  exit 1
fi

if [ ! -f "$file" ]; then
  echo "File not found!"
  exit 1
fi

# POST the file to $server/api/deb/upload
curl --progress-bar -X POST "$server/api/deb/upload" -F "file=@$file"
