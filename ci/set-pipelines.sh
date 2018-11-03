#!/bin/bash

set -e

if [ "$1" = "" ]; then
  echo $0: usage: $0 target
  exit
fi

target=$1
this_directory=`dirname "$0"`

fly -t $target set-pipeline -p rate-limit-route-service -c ${this_directory}/../rate-limit-route-service/ci/pipeline.yml

fly -t $target set-pipeline -p rest-data-service -c ${this_directory}/../rest-data-service/ci/pipeline.yml

fly -t $target set-pipeline -p web-ui -c ${this_directory}/../web-ui/ci/pipeline.yml

fly -t $target set-pipeline -p uaa -c ${this_directory}/../uaa/ci/pipeline.yml

fly -t $target set-pipeline -p uaa-guard-proxy -c ${this_directory}/../uaa-guard-proxy/ci/pipeline.yml
