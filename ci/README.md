# CI for Developer Training Class Apps

Each app contains its own pipeline.  Apps in this repo are used in the Cloud Foundry Foundation [Developer Training Course](https://www.cloudfoundry.org/trainings/cloud-foundry-developers-2/).

## Overview

The pipeline prepares the applications for inclusion in the builds of the course materials which occurs in the course repository.

## Prerequisites

In order to run the pipelines, you need the following:

* Artifact Bucket: The bucket is used to house app artifacts. Artifacts included in the class site will be picked up from this bucket.
  * S3 bucket with versioning enabled
  * A user that has all access on the bucket (example IAM policy below)

  ```
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::<YOUR_BUCKET>",
                "arn:aws:s3:::<YOUR_BUCKET>/*"
            ]
        }
    ]
  }
  ```

* Cloud Foundry: Some of the pipelines will run integration tests against apps running in CF.
  * You must have a MySQL available in the marketplace
  * An org, space and user for deploying and running tests

## Config

The following config values are required:

**S3 Artifact Bucket:**
  * assets_bucket_name
  * assets_bucket_region
  * aws_access_key_id
  * aws_secret_access_key

**CF for Integration Tests**

  * cf_it_api_url
  * cf_it_username
  * cf_it_password
  * cf_it_org
  * cf_it_skip_ssl
  * cf_it_space
  * cf_it_app_domain

**MySQL for Integration Testing the rest-data-service**

  * mysql_it_service_name
  * mysql_it_plan_name

We recommend creating a team (perhaps called `cff`) in concourse and storing the values in credhub as:  `/concourse/cff/${param}` so they are shared with all pipelines.

## Running

A bash script is included that will create all of the pipelines for you.  

```
ci/set-pipelines.sh <concourse-target>
```

Another bash script is included to unpause each pipeline.

```
ci/unpause-pipelines.sh <concourse-target>
```
