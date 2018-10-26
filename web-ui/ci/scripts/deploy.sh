#!/bin/bash

set -eu

dirname=$(dirname $0)

. $dirname/../../../../ci/solution_setup.sh

pushd $dirname
  git_sha=$(get_short_revision ../../../../)
popd
app_name=ruby-web-ui-${git_sha}
static_app_name=ruby-static-ui-${git_sha}
data_app_name=data_service-${git_sha}
rest_service_name=rest-backend-ruby-${git_sha}

pushd $dirname/../../../../../rest-data-service-jar/
  cf push $data_app_name -p rest-data-service.jar --random-route
popd

data_route=$(get_route $data_app_name)
curl -Lso/dev/null $data_route || (echo "failed to reach $data_route" && exit 1)

pushd $dirname/../../
  cf push $app_name -m 256M --no-start
  cf cups $rest_service_name -p "{\"url\":\"$data_route\"}"
  cf bind-service $app_name $rest_service_name
  cf start $app_name

  cf push $static_app_name -b https://github.com/cloudfoundry/staticfile-buildpack.git
popd

route=$(get_route $app_name)
static_route=$(get_route $static_app_name)

curl -Lso/dev/null $route || (echo "failed to reach $route" && exit 1)
curl -Lso/dev/null $static_route || (echo "failed to reach $static_route" && exit 1)
