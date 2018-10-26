# frozen_string_literal: true

$LOAD_PATH << File.expand_path('lib')

require 'status_manager'
require 'people_data_service'
require 'app_scheduler'

$stdout.sync = true

AppScheduler.new(StatusManager.new(PeopleDataService.new(rest_backend_url))).run.join
