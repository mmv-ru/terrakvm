#!/bin/sh
cd "$(dirname "$0")"

docker build -t mmv/terrakvm \
             $@ \
             ./

# Save Docker image to file
#docker save mmv/terrakvm:latest |pxz > terrakvm.tar.xz
