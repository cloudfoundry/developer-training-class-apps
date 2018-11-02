#!/bin/bash

set -eu

. source/ci/solution_setup.sh

git_sha=$(get_short_revision source)

echo "GIT_SHA: ${git_sha}"

app_name=ruby-web-ui-${git_sha}
static_app_name=ruby-static-ui-${git_sha}
data_app_name=data_service-${git_sha}
rest_service_name=rest-backend-ruby-${git_sha}

cf push $data_app_name -p rest-data-service-jar/rest-data-service.jar --random-route

data_route=$(get_route $data_app_name)
curl -Lso/dev/null $data_route || (echo "failed to reach $data_route" && exit 1)


cf push $app_name -m 256M --no-start -p source/web-ui/
cf cups $rest_service_name -p "{\"url\":\"$data_route\"}"
cf bind-service $app_name $rest_service_name
cf start $app_name

cf push $static_app_name -b https://github.com/cloudfoundry/staticfile-buildpack.git -p source/web-ui/


route=$(get_route $app_name)
static_route=$(get_route $static_app_name)

curl -Lso/dev/null $route || (echo "failed to reach $route" && exit 1)
curl -Lso/dev/null $static_route || (echo "failed to reach $static_route" && exit 1)
