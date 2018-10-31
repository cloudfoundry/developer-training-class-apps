#!/bin/bash

set -eu

dirname=$(dirname $0)

. $dirname/../../../ci/solution_setup.sh

app_name='uaa-95810691'

cf delete -f -r $app_name || echo "$app_name could not be deleted"
