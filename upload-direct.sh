#!/bin/bash -e
remote = "100.114.82.91"
file = $1
if [ -z "$file" ]; then
  echo "Usage: $0 <file>"
  exit 1
fi

if [ ! -f "$file" ]; then
  echo "File not found!"
  exit 1
fi

rsync