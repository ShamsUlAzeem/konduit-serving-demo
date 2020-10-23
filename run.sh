#!/usr/bin/env bash

docker run -i -t -p 8889:8889 nec-docker:1.4 /bin/bash -c "export PATH=/opt/conda/bin:/root/konduit/bin:${PATH} && . activate base && jupyter notebook --notebook-dir=/root/konduit --ip='*' --port=8889 --no-browser --allow-root"