# frozen_string_literal: true

require 'controllers/people_data_service.rb'

RSpec.describe PeopleDataService do
  let(:base) { 'http://roster-app.example.com' }
  let(:expected_data) do
    [{
      'firstName' => 'foo', 'lastName' => 'bar'
    }, {
      'firstName' => 'baz', 'lastName' => 'bray', 'email' => 'test@example.com', 'phoneNumber' => '1234', 'companyName' => 'foo Co.'
    }]
  end
  subject(:people_data_service) { PeopleDataService.new(base) }

  it 'returns People' do
    expect(subject.people).to be_a(People)
  end

  it 'returns the correct data' do
    people = subject.people
    puts people.class
    expect(people).to eq(People.new(expected_data))
  end
end
