#!/bin/bash -e

server="https://robo-rpi.tail39b6e.ts.net"

curl -X POST $server/api/deb/refresh-apt