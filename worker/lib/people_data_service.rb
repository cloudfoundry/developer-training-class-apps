# frozen_string_literal: true

require 'httparty'
require 'models/people'
require 'storage_error'

# Restful webservice consumer for People
class PeopleDataService
  include HTTParty
  format :json
  headers 'Accept' => 'application/hal+json'
  headers 'Content-Type' => 'application/json'

  def initialize(base)
    self.class.base_uri base
    @options = {}
  end

  def people
    raise StorageError, 'No URL set' if self.class.base_uri.to_s.empty?
    people_data = self.class.get('/people', @options)
    raise StorageError, people_data.code unless people_data.success?
    People.new(people_data['_embedded']['people'])
  rescue StandardError => e
    raise StorageError, e
  end

  def store_status(person_status)
    raise StorageError, 'No URL set' if self.class.base_uri.to_s.empty?
    response = self.class.post('/people_status', body: person_status.to_json(self.class.base_uri))
    raise StorageError, response.body unless response.success?
    true
  rescue StandardError => e
    raise StorageError, e
  end
end
