#!/bin/bash

set -eu

dirname=$(dirname $0)

. $dirname/../../../../ci/solution_setup.sh
pushd $dirname
  git_sha=$(get_short_revision ../../../../)
popd
app_name=worker-app-${git_sha}
roster_name=worker-roster-${git_sha}
service_name=rest-backend-worker-${git_sha}

cf unbind-service $app_name $service_name || echo "$service_name could not be unbound from $app_name"
cf delete-service -f $service_name || echo "$service_name could not be deleted"
cf delete -f -r $roster_name || echo "$roster_name could not be deleted"
cf delete -f -r $app_name || echo "$app_name could not be deleted"
