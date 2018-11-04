#!/bin/bash

cd source/rest-data-service

mvn clean package

cp target/*.jar ../../artifacts/rest-data-service.jar
