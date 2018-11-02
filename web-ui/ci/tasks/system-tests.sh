#!/bin/bash

set -eu


. source/ci/solution_setup.sh

git_sha=$(get_short_revision source)

app_name=ruby-web-ui-${git_sha}
static_app_name=ruby-static-ui-${git_sha}
uaa_name=uaa-${git_sha}

route=$(get_route $app_name)
static_route=$(get_route $static_app_name)
uaa_route=$(get_route $uaa_name)

curl --silent $route | grep -q "Welcome" || (echo "was not welcome at $route" && exit 1)
curl --silent $static_route | grep -q "Staticfile"  || (echo "was not static at $static_route" && exit 1)

# Check we can still access the app
curl --silent $route | grep -q "anonymous" || (echo "No anonymous access to web ui" && exit 1)

# Install the uaac ruby gem
gem install cf-uaac

# create an access token using uaac
uaac target https://$uaa_route
uaac token get marissa koala
access_token=$(grep "access_token:" ~/.uaac.yml | awk {'print $2'})

# access the app passing in the access token & check that the page detects who the access token was for
curl --silent -L -H "X-Auth-Token: $access_token" $route | grep -q "marissa" || (echo "No authenticated access" && exit 1)
