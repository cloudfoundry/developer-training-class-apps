# Web UI

This is a ruby web app which acts as a wrapper for the rest-data-service & any other backend services that comprise this course.

## Running Locally

```
$ bundle install
$ rackup
```

## Running on CF

```
$ cf push
```

## CI/Testing

Coming soon. In the meantime `bundle exec rspec`

## Ruby / buildpack / WEBrick versions

This app failed when accessed via the `cf-uaa-guard-service`, when both were deployed on Swisscom, although the same setup worked on PWS.
The fix was to set the Ruby version to be 2.4.0 (upgraded for 2.3.0) & always deploy using the buildpack from Github (see version in `manifest.yml`). The `ruby_buildpack` version installed to Swisscom did not support Ruby v2.4.0
