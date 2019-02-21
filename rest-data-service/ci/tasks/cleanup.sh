#!/bin/bash

set -eu

. source/ci/solution_setup.sh

app_name=rest-data-service
db_name=rest-data-service-db

cf delete -f -r $app_name || echo "$app_name could not be deleted"
cf delete-service -f $db_name || echo "$db_name could not be deleted"
