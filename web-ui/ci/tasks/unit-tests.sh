#!/bin/bash

set -eu


cd source/web-ui
gem install bundle
bundle install
bundle exec rspec
gem install rubocop
rubocop
