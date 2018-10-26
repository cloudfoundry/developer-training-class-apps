#!/bin/bash

set -eu

dirname=$(dirname $0)

. $dirname/../../../../ci/solution_setup.sh
pushd $dirname
  git_sha=$(get_short_revision ../../../../)
popd
roster_name=worker-roster-${git_sha}
service_name=rest-backend-worker-${git_sha}
app_name=worker-app-${git_sha}

cf push $roster_name \
-p $dirname/../../../../../rest-data-service-jar/rest-data-service.jar \
-i 1 -m 750M \
-b java_buildpack \
--random-route

roster_route=$(get_route $roster_name)

insert_response=$(curl -H "Content-Type: application/json" -X POST -d '{"firstName":"foo", "lastName": "bar"}'  http://$roster_route/people)
person_href=$(echo $insert_response | jq --raw-output '._links.person.href')
echo "person_href: $person_href"

cf cups $service_name -p "{\"url\":\"https://$roster_route\"}"

cf push $app_name -i 1 -m 256M -u none -o engineerbetter/worker-image --no-route --no-start

cf bind-service $app_name $service_name

cf start $app_name

sleep 11

app_logs=$(cf logs $app_name --recent)

echo "$app_logs" | grep -q "recording status" || (echo "Unable to find 'recording status' in $app_name logs" && exit 1)

number=$(curl --silent "https://$roster_route/people_status" | jq --raw-output '.page.totalElements')

[[ $number -gt 0 ]] || (echo "Statuses not being stored" && exit 1)
