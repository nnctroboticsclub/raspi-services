#!/bin/bash -e

DEPLOY_ROOT=~/services

ssh robo-rpi "mkdir -p $DEPLOY_ROOT"

rsync -avz --delete ./app robo-rpi:$DEPLOY_ROOT
rsync -avz --delete ./nginx robo-rpi:$DEPLOY_ROOT
rsync -avz --delete ./docker-compose.yml robo-rpi:$DEPLOY_ROOT
