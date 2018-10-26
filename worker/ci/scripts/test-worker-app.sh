#!/bin/bash

set -eu

dirname=$(dirname $0)

pushd $dirname/../../
  gem install bundle
  bundle install
  bundle exec rspec
  gem install rubocop
  rubocop
popd
