# frozen_string_literal: true

# Model class for a person
class Person
  def initialize(first, last, email, phone, company)
    @first = first
    @last = last
    @email = email
    @phone = phone
    @company = company
  end

  def ==(other)
    other.class == self.class && other.first == @first && other.last == @last && other.email == @email && other.phone == @phone && other.company == @company
  end

  attr_reader :first, :last, :email, :phone, :company
end
