#!/bin/bash

set -eu

. source/ci/solution_setup.sh

git_sha=$(get_short_revision source)

app_name=ruby-web-ui-${git_sha}
static_app_name=ruby-static-ui-${git_sha}
data_app_name=data_service-${git_sha}
rest_service_name=rest-backend-ruby-${git_sha}
uaa_app_name=uaa-${git_sha}
uaa_service_name=uaa-tokens-${git_sha}

cf delete -f -r $uaa_app_name || echo "$uaa_app_name could not be deleted"
cf delete -f -r $static_app_name || echo "$static_app_name could not be deleted"
cf delete -f -r $app_name || echo "$app_name could not be deleted"
cf delete-service -f $rest_service_name || echo "$rest_service_name could not be deleted"
cf delete-service -f $uaa_service_name || echo "$uaa_service_name could not be deleted"
cf delete -f -r $data_app_name || echo "$data_app_name could not be deleted"
