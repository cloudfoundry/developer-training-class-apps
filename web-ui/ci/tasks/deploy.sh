#!/bin/bash

set -eu

. source/ci/solution_setup.sh

app_name=ruby-web-ui
static_app_name=ruby-static-ui
data_app_name=web-ui-data_service
rest_service_name=rest-backend-ruby
uaa_app_name=web-ui-uaa
uaa_service_name=uaa-tokens

cf push $data_app_name -p rest-data-service-jar/rest-data-service.jar -d ${CF_APP_DOMAIN} -b java_buildpack

data_route=$(get_route $data_app_name)
curl -Lso/dev/null $data_route || (echo "failed to reach $data_route" && exit 1)

cf push $app_name -m 256M --no-start -p source/web-ui/ -f source/web-ui/manifest.yml -d ${CF_APP_DOMAIN} -n ${app_name}
cf cups $rest_service_name -p "{\"url\":\"$data_route\"}"
cf bind-service $app_name $rest_service_name
cf start $app_name

cf push $static_app_name -m 128M -b https://github.com/cloudfoundry/staticfile-buildpack.git -p source/web-ui/ -d ${CF_APP_DOMAIN}

route=$(get_route $app_name)
static_route=$(get_route $static_app_name)

curl -Lso/dev/null $route || (echo "failed to reach $route" && exit 1)
curl -Lso/dev/null $static_route || (echo "failed to reach $static_route" && exit 1)

uaa_route="${uaa_app_name}.${CF_APP_DOMAIN}"
# Push the UAA War file and then get its route
cf push $uaa_app_name -f uaa-manifest/uaa-manifest.yml -p uaa-war/uaa.war --var route=${uaa_route} -m 1G

# Create a UPSI for the UAA app
cf cups $uaa_service_name -p "{\"url\":\"https://$uaa_route\",\"client_name\":\"oauth_showcase_authorization_code\",\"client_secret\":\"secret\"}"

# Bind the UAA UPSI to the Web UI app
cf bind-service $app_name $uaa_service_name
cf restart $app_name
