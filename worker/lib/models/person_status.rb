# frozen_string_literal: true

# Model class for a person
class PersonStatus
  def initialize(person, status, date)
    @person = person
    @status = status
    @date = date
  end

  def to_json(base_url)
    { status: status, updatedTime: date, person: person.href(base_url) }.to_json
  end

  def ==(other)
    other.class == self.class && other.person == @person && other.status == @status && other.date == @date
  end

  attr_reader :person, :status, :date
end
