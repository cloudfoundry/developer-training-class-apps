# frozen_string_literal: true

require 'sinatra'

$stdout.sync = true
$stderr.sync = true

$LOAD_PATH << File.expand_path('app')

Dir['./app/controllers/*.rb'].each { |file| require file }
run ApplicationController
