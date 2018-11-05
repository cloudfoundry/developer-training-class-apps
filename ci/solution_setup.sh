#!/bin/bash

cf_login() {
  # For testing on pcfdev
  if $CF_SKIP_SSL; then
    SKIP_SSL="--skip-ssl-validation"
  else
    SKIP_SSL=""
  fi

  cf login -a $CF_API_URL -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE $SKIP_SSL
}

echo "Attempting to log in"
cf target | grep -q "User:" || cf_login

get_short_revision() {
  set +u
  if [ ! -z "$GIT_SHA" ]; then
    echo $GIT_SHA
    return
  fi
  set -u
  if [ -f "$1/.git/ORIG_HEAD" ]; then
    HEAD=$(git log -1 --oneline| awk {'print $1'})
  else
    HEAD=$(cat $1/.git/HEAD)
  fi
  echo ${HEAD:0:7}
}

get_route() {
  guid=`cf app --guid $1`
  host=`cf curl /v2/apps/${guid}/routes | jq -r .resources[0].entity.host`
  domain_url=`cf curl /v2/apps/${guid}/routes | jq -r .resources[0].entity.domain_url`
  domain=`cf curl $domain_url | jq -r .entity.name`
  echo ${host}.${domain}
}

get_host() {
  echo $(get_route $1) | cut -d '.' -f 1
}
