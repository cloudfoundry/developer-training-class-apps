#!/bin/bash

set -eu

. source/ci/solution_setup.sh

git_sha=$(get_short_revision source)

app_name=uaa-${git_sha}

route="${app_name}.${CF_APP_DOMAIN}"

# fail fast if we cannot install the required gem
gem install cf-uaac || (echo "unable to install the required gem" && exit 1)

cf push $app_name -m 1G -f source/uaa/uaa-manifest.yml -p uaa-war/uaa.war --var route=${route}

curl -L --fail -o/dev/null $route || (echo "Could not reach $app_name with valid response" && exit 1)

uaac target $route || (echo "Unable to target uaa" && exit 1)
uaac token get marissa koala || (echo "Unable to get default user token from uaa" && exit 1)
uaac token client get admin -s adminsecret || (echo "Unable to get admin client token from uaa" && exit 1)
uaac client get oauth_showcase_authorization_code | grep -q " authorization_code " || (echo "Unable to get correct Oauth client from uaa" && exit 1)
