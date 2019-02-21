#!/bin/bash

set -e

if [ "$1" = "" ]; then
  echo $0: usage: $0 target
  exit
fi

target=$1
this_directory=`dirname "$0"`

echo "Creating pipeline: rate-limit-route-service"
fly -t $target set-pipeline -p rate-limit-route-service -c ${this_directory}/../rate-limit-route-service/ci/pipeline.yml

echo "Creating pipeline: rest-data-service"
fly -t $target set-pipeline -p rest-data-service -c ${this_directory}/../rest-data-service/ci/pipeline.yml

echo "Creating pipeline: web-ui"
fly -t $target set-pipeline -p web-ui -c ${this_directory}/../web-ui/ci/pipeline.yml

echo "Creating pipeline: uaa"
fly -t $target set-pipeline -p uaa -c ${this_directory}/../uaa/ci/pipeline.yml

echo "Creating pipeline: uaa-guard-proxy"
fly -t $target set-pipeline -p uaa-guard-proxy -c ${this_directory}/../uaa-guard-proxy/ci/pipeline.yml
