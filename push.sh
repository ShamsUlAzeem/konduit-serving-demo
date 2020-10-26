#!/usr/bin/env bash

docker tag konduitai/demo:1.0 docker.pkg.github.com/konduitai/konduit-serving-demos/quick-start:latest

docker push docker.pkg.github.com/konduitai/konduit-serving-demos/quick-start:latest

docker tag konduitai/demo:1.0 konduit/konduit-serving-demo:latest

docker push konduit/konduit-serving-demo:latest