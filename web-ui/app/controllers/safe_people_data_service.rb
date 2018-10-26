# frozen_string_literal: true

require 'httparty'
require 'models/people'

# Restful webservice consumer for People with graceful degredation
class SafePeopleDataService
  include HTTParty
  format :json

  def initialize(base)
    self.class.base_uri base
    @options = {}
  end

  def people
    people_data = self.class.get('/people', @options)
    People.new(people_data['_embedded']['people'])
  rescue StandardError
    nil
  end
end
