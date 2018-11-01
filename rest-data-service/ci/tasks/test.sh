#!/bin/bash

set -eu

app_name=$RANDOM$RANDOM
service_name=$RANDOM$RANDOM

dirname=$(dirname $0)

. source/ci/solution_setup.sh

echo "Create database service"
cf create-service $MYSQL_SERVICE_NAME $MYSQL_PLAN_NAME $service_name

echo "Push app"
cf push $app_name -p source/rest-data-service/target/rest-data-service.jar --random-route --no-start -m 750M
cf set-env $app_name ROSTER_A bar
cf set-env $app_name ROSTER_C foo
cf set-env $app_name ROSTER_B baz

echo "Bind service to app"
cf bind-service $app_name $service_name

echo "Start app"
cf start $app_name

route=$(get_route $app_name)

insert_response=$(curl -H "Content-Type: application/json" -X POST -d '{"firstName":"foo", "lastName": "bar"}'  http://$route/people)
person_href=$(echo $insert_response | jq --raw-output '._links.person.href')
echo "person_href: $person_href"

# insert the personStatus data
curl -H "Content-Type: application/json" -X POST -d "{\"status\" : \"Active\", \"updatedTime\" : \"2017-03-10T13:16:36.000+0000\", \"person\" : \"${person_href}\"}"  http://$route/people_status
status_output=$(curl -H "Content-Type: application/json" $person_href/personStatuses)

output=$(curl --silent $person_href)

echo "Check that key-value pairs are stored"
[[ $(echo $output |  jq --raw-output '.firstName') == "foo" ]] || (echo "First name not found" && exit 1)
[[ $(echo $output |  jq --raw-output '.lastName') == "bar" ]] || (echo "Last name not found" && exit 1)
[[ $(echo $status_output |  jq --raw-output '._embedded.people_status[0].status') == "Active" ]] || (echo "Status field not found" && exit 1)
[[ $(echo $status_output |  jq --raw-output '._embedded.people_status[0].updatedTime') == "2017-03-10T13:16:36.000+0000" ]] || (echo "Updated field not found" && exit 1)

cf restart $app_name

output=$(curl --silent $person_href)

echo "Check that key-value pairs are still stored"
[[ $(echo $output |  jq --raw-output '.firstName') == "foo" ]] || (echo "State lost" && exit 1)
[[ $(echo $output |  jq --raw-output '.lastName') == "bar" ]] || (echo "State lost" && exit 1)

echo "Data Tests passed"

app_details=$(curl http://$route/app-details)

[[ $(echo $app_details | jq --raw-output '.appName') == $app_name ]] || (echo "This is not the app you're looking for" && exit 1)
$(echo $app_details | jq '.serviceUrl' | grep -qi mysql) || (echo "mysql service not being used as the app datasource" && exit 1)
$(echo $app_details | jq '.rosterVars.ROSTER_A' | grep -qi bar) || (echo "ROSTER_A env var not found" && exit 1)
$(echo $app_details | jq '.rosterVars.ROSTER_B' | grep -qi baz) || (echo "ROSTER_B env var not found" && exit 1)
$(echo $app_details | jq '.rosterVars.ROSTER_C' | grep -qi foo) || (echo "ROSTER_C env var not found" && exit 1)

echo "App Details Tests passed"

set +e
cf events $app_name | grep CRASHED
[[ $? -gt 1 ]] || (echo "App crashed before time" && exit 1)

output=$(curl --silent http://$route/kill)

cf events $app_name | grep CRASHED
[[ $? -eq 0 ]] || (echo "App failed to crash when expected" && exit 1)

echo "Kill endpoint tests passed"
echo "All tests passed"

echo "Cleaning up"
# Not on course. Tidy up...
cf delete -f -r $app_name
cf delete-service -f $service_name
