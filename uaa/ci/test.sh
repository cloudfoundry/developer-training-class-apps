#!/bin/bash

set -eu

app_name=uaa-95810691

dirname=$(dirname $0)

. $dirname/../../../ci/solution_setup.sh

# fail fast if we cannot install the required gem
gem install cf-uaac || (echo "unable to install the required gem" && exit 1)

cf push $app_name -m 1G -f ../uaa-war-manifest-test/uaa-cf-application.yml -p ../uaa-war-test/cloudfoundry-identity-uaa-3.11.0.war

route=$(get_route $app_name)
curl -L --fail -o/dev/null $route || (echo "Could not reach $app_name with valid response" && exit 1)

uaac target $route || (echo "Unable to target uaa" && exit 1)
uaac token get marissa koala || (echo "Unable to get default user token from uaa" && exit 1)
uaac token client get admin -s adminsecret || (echo "Unable to get admin client token from uaa" && exit 1)
uaac client get oauth_showcase_authorization_code | grep -q " authorization_code " || (echo "Unable to get correct Oauth client from uaa" && exit 1)
