# CI for Developer Training Class Apps

The concourse pipeline in this folder builds the apps used in the Cloud Foundry Foundation [Developer Training Course](https://www.cloudfoundry.org/trainings/cloud-foundry-developers-2/).

## Overview

The pipeline prepares the applications for inclusion in the builds of the course materials.


## Prerequisites


CF instance w/ MySQL
CF account to deploy and run tests on

You need an AWS S3 bucket with versioning enabled (along with a user that has all access on the bucket




## Config

The following config values are required:

cf_api_url
cf_user_name
cf_password
cf_org
cf_skip_ssl
cf_space
cf_app_domain

assets_bucket_name
assets_bucket_region

aws_access_key_id
aws_secret_access_key

mysql_service_name
mysql_plan_name

github_private_key
