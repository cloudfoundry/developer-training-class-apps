#!/bin/bash

cd uaa-source

./gradlew clean assemble

cp /uaa/build/libs/*.war artifacts/uaa.war
