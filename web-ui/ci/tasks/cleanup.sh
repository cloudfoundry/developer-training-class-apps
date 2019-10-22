#!/bin/bash

set -eu

. source/ci/solution_setup.sh

app_name=ruby-web-ui-class-app
static_app_name=ruby-static-ui-class-app
data_app_name=web-ui-data_service
rest_service_name=rest-backend-ruby
uaa_app_name=web-ui-uaa-class-app
uaa_service_name=uaa-tokens

cf delete -f -r $uaa_app_name || echo "$uaa_app_name could not be deleted"
cf delete -f -r $static_app_name || echo "$static_app_name could not be deleted"
cf delete -f -r $app_name || echo "$app_name could not be deleted"
cf delete-service -f $rest_service_name || echo "$rest_service_name could not be deleted"
cf delete-service -f $uaa_service_name || echo "$uaa_service_name could not be deleted"
cf delete -f -r $data_app_name || echo "$data_app_name could not be deleted"
