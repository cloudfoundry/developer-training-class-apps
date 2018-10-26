# rest-data-service

This folder contains a simple RESTful data service app, built using Spring, for the purpose of supporting the exercises in this training course.

## To build

```
mvn clean package
```

## To test

```
CF_API_URL=https://api.run.pivotal.io \
CF_USER_NAME=cfcdtesting@engineerbetter.com \
CF_PASSWORD='the_password' \
CF_ORG=engineerbetter \
CF_SPACE=cfcd \
CF_SKIP_SSL=false \
./ci/test.sh
```
