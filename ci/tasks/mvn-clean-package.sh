#!/bin/bash

cd source/${APP_PATH}

mvn clean package

cp target/*.jar ../../artifacts/
