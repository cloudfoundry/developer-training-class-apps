# worker

This is a ruby app that is intended to be deployed via Docker, which will augment the people data in the rest-data-service database with 'status' data. It will also provide a TCP routing interface in support of the (optional) TCP Routing course exercise.

## Setting the pipeline

Fill in the secrets in `ci/credentials.yml` and move it to the `ci/credentials` directory so it doesn't get committed. Then set the pipeline using:

```
fly -t cfcd set-pipeline \
-p cfcd-docker-app \
-c ci/pipeline.yml \
--var "private_key=$(cat ~/path/to/id_rsa)" \
--load-vars-from ci/credentials/credentials.yml
```
