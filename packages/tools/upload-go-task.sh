#!/bin/bash -e
. `dirname $0`/../.env

group=$1

if [ -z "$group" ]; then
  echo "Usage: $0 <group>"
  exit 1
fi

wget https://github.com/go-task/task/releases/download/v3.43.3/task_linux_amd64.deb -O task.deb

curl --progress-bar -X POST "$server/api/deb/upload?group=$group" -F "file=@task.deb"
rm -f task.deb
echo""

echo "Uploaded task.deb to $server/api/deb/upload?group=$group"