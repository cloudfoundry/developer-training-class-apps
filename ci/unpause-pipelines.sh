#!/bin/bash

set -e

if [ "$1" = "" ]; then
  echo $0: usage: $0 target
  exit
fi

target=$1
this_directory=`dirname "$0"`

fly -t $target unpause-pipeline -p rate-limit-route-service

fly -t $target unpause-pipeline -p rest-data-service

fly -t $target unpause-pipeline -p web-ui

fly -t $target unpause-pipeline -p uaa

fly -t $target unpause-pipeline -p uaa-guard-proxy
