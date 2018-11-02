#!/bin/bash

set -eu


. source/ci/solution_setup.sh

git_sha=$(get_short_revision source)

app_name=uaa-${git_sha}

cf delete -f -r $app_name 
