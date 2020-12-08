#!/usr/bin/env bash

rm -rf compose/data-grafana/png/
docker build --tag konduitai/demo:1.1 .
