#!/usr/bin/env bash

docker run -i -t -p 8889:8889 konduitai/demo:1.0 /bin/bash -c "export PATH=/opt/conda/bin:/root/konduit/bin:${PATH} && . activate base && jupyter notebook --notebook-dir=/root/konduit --ip='*' --port=8889 --no-browser --allow-root"