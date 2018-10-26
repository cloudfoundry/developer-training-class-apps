# frozen_string_literal: true

# Model class for a person
class Person
  def initialize(uuid, first, last, email, phone, company)
    @uuid = uuid
    @first = first
    @last = last
    @email = email
    @phone = phone
    @company = company
  end

  def href(url)
    "#{url}/people/#{uuid}"
  end

  def ==(other)
    other.class == self.class && other.uuid == @uuid && other.first == @first && other.last == @last && other.email == @email && other.phone == @phone && other.company == @company
  end

  attr_reader :uuid, :first, :last, :email, :phone, :company
end
