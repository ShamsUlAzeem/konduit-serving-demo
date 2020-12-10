#!/usr/bin/env bash

if [[ $(docker info | grep Runtimes:) == *"nvidia"* ]]; then
    export RUNTIME=nvidia
else
    export RUNTIME=runc
fi

docker-compose up