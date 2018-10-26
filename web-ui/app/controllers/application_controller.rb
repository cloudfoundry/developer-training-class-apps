# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'models/logged_in'
require 'controllers/people_data_service'
require 'controllers/safe_people_data_service'

# MVC-style controller
class ApplicationController < Sinatra::Base
  set :views, (proc { File.join(root, '../views') })
  set :show_exceptions, true

  def initialize
    super
    @logged_in ||= LoggedIn.new
  end

  get '/' do
    logged_in.check_token(request)
    rest_backend_url
    erb :welcome
  end

  get '/cascade' do
    logged_in.check_token(request)
    rest_backend_url
    erb :cascade
  end

  get '/people' do
    logged_in.check_token(request)
    url = rest_backend_url
    unless url
      halt 500, "Please connect your app to the rest data service\n"
      return
    end
    service = PeopleDataService.new(url)
    @people = service.people
    erb :people
  end

  get '/people-safe' do
    logged_in.check_token(request)
    url = rest_backend_url
    unless url
      halt 500, "Please connect your app to the rest data service\n"
      return
    end
    service = SafePeopleDataService.new(url)
    @people = service.people
    if @people.nil?
      status 503
      erb :failure
    else
      erb :people
    end
  end

  get '/secure' do
    halt 401, "Not authorized\n" unless logged_in.check_token(request)
    "You are secure! #{logged_in.message}"
  end

  attr_reader :logged_in
end

def vcap_services
  ENV.fetch('VCAP_SERVICES', nil)
end

def rest_backend_url
  return nil if vcap_services.nil?
  json = JSON.parse(vcap_services)
  service_array = json['user-provided']
  service_array.select do |service|
    service['name'].start_with?('rest-backend')
  end.first['credentials']['url']
end
