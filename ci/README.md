# CI for Developer Training Class Apps

 Each app contains its own pipeline definition.  Apps in this repo are used in the Cloud Foundry Foundation [Developer Training Course](https://www.cloudfoundry.org/trainings/cloud-foundry-developers-2/).

## Overview

The pipeline prepares the applications for inclusion in the builds of the course materials.


## Prerequisites

In order to run the pipelines, you need the following:

* CF instance w/ MySQL
* CF account to deploy and run tests on
* You need an AWS S3 bucket with versioning enabled (along with a user that has all access on the bucket

## Config

The following config values are required:

* cf_api_url
* cf_user_name
* cf_password
* cf_org
* cf_skip_ssl
* cf_space
* cf_app_domain
* assets_bucket_name
* assets_bucket_region
* aws_access_key_id
* aws_secret_access_key
* mysql_service_name
* mysql_plan_name

We recommend creating a team (perhaps called `cff`) in concourse and storing the values in credhub as:  `/concourse/cff/${param}`.

## Running

A bash script is included that will create all of the pipelines for you.  

```
ci/set-pipelines.sh <concourse-target>
```

Another bash script is included to unpause each pipeline.

```
ci/unpause-pipelines.sh <concourse-target>
```
