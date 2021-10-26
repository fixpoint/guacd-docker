#!/bin/bash
ROOT="$(cd $(dirname $0); pwd)"

IMAGE=$1; shift
GUACD_VERSION=$1; shift

cd $ROOT/../
docker buildx build \
  $@ \
  --cache-from=${IMAGE}/cache \
  --cache-from=${IMAGE} \
  --build-arg GUACD_VERSION=${GUACD_VERSION} \
  -t ${IMAGE}:${GUACD_VERSION} \
  -t ${IMAGE}:latest \
  .
