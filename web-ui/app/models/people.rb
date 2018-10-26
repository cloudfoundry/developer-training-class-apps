# frozen_string_literal: true

require 'models/person'

# Model class for multiple persons
class People
  def initialize(people_data)
    @persons = []
    people_data.each do |person_data|
      persons.push Person.new(
        person_data['firstName'],
        person_data['lastName'],
        person_data['email'],
        person_data['phoneNumber'],
        person_data['companyName']
      )
    end
  end

  def ==(other)
    other.class == self.class && other.persons == persons
  end

  attr_reader :persons
end
