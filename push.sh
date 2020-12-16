#!/usr/bin/env bash

CHIP=$(echo "${1:-CPU}" | awk '{ print tolower($0)}')

if [[ "$CHIP" != "cpu" && "$CHIP" != "gpu" ]]
then
    echo "Selected CHIP should be one of [CPU, GPU]"
    echo "Usage: bash build.sh CPU"
    echo "Usage with rebuilding JAR file: bash push.sh [CPU|GPU]"
    exit 1
fi

echo "Pushing for CHIP=$CHIP"

docker push docker.pkg.github.com/konduitai/konduit-serving-demos/quick-start:"${CHIP}"
docker push konduit/konduit-serving-demo:"${CHIP}"