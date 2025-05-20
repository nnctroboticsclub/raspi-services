#!/bin/bash -e

server="https://robo-rpi.tail39b6e.ts.net"
group=$1

if [ -z "$group" ]; then
  echo "Usage: $0 <group>"
  exit 1
fi

curl -X POST $server/api/deb/refresh-apt?group=$group