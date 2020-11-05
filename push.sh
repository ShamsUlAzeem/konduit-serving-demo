#!/usr/bin/env bash

docker tag konduitai/demo:gpu docker.pkg.github.com/konduitai/konduit-serving-demos/quick-start:gpu

docker push docker.pkg.github.com/konduitai/konduit-serving-demos/quick-start:gpu

docker tag konduitai/demo:gpu konduit/konduit-serving-demo:gpu

docker push konduit/konduit-serving-demo:gpu