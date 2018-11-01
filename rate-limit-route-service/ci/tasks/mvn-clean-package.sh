#!/bin/bash

cd source/rate-limit-route-service

mvn clean package

cp target/*.jar ../../artifacts/
