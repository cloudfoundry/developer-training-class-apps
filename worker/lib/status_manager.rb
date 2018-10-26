# frozen_string_literal: true

require 'date'
require 'models/person_status'

# Class for managing the recording of people statuses
class StatusManager
  @status_codes = %w[active inactive]

  class << self
    attr_accessor :status_codes
  end

  def initialize(people_data_service)
    @people_data_service = people_data_service
  end

  def record_random_status
    people = people_data_service.people
    raise 'No people data found' if people.persons.empty?
    random_person = people.persons.sample
    random_status = self.class.status_codes.sample
    now = DateTime.now
    raise 'Unable to store status' unless people_data_service.store_status(PersonStatus.new(random_person, random_status, now.to_s))
    random_person.uuid
  end

  private

  attr_reader :people_data_service
end
