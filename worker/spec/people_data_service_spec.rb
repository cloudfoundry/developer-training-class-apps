# frozen_string_literal: true

require 'people_data_service'
require 'models/person_status'

RSpec.describe PeopleDataService do
  let(:base) { 'http://roster-app.example.com' }
  let(:expected_data) do
    people = People.new([])
    people.persons = [
      Person.new(
        'fe3a7b00-f318-4254-9067-32e853f4e4e5',
        'foo',
        'bar',
        nil, nil, nil
      ),
      Person.new(
        '4dee71c5-5a55-44d3-8319-8717820fcf78',
        'baz',
        'bray',
        'test@example.com',
        '1234',
        'foo Co.'
      )
    ]
    people
  end

  describe 'the "people" method' do
    context 'when the backend service is bound' do
      subject(:people_data_service) { PeopleDataService.new(base) }
      it 'returns People' do
        expect(subject.people).to be_a(People)
      end

      it 'returns the correct data' do
        people = subject.people
        expect(people).to eq(expected_data)
      end
    end

    context 'when the backend service is not bound' do
      subject(:people_data_service) { PeopleDataService.new(nil) }

      before(:each) do
        dos = PeopleDataService.default_options
        dos[:base_uri] = nil
        PeopleDataService.class_variable_set(:@@default_options, dos)
      end

      it 'raises a suitable error' do
        expect { subject.people }.to raise_error StorageError
      end
    end
  end

  describe 'the store_status method' do
    let(:status) { PersonStatus.new(Person.new('foo', nil, nil, nil, nil, nil), 'Active', '2017-03-10T13:16:36.000+0000') }

    context 'when the backend service is bound' do
      subject(:people_data_service) { PeopleDataService.new(base) }

      it 'returns People' do
        expect([true, false]).to include(subject.store_status(status))
      end

      it 'returns the correct data' do
        result = subject.store_status(status)
        expect(result).to be_truthy
      end
    end

    context 'when the backend service is not bound' do
      subject(:people_data_service) { PeopleDataService.new(nil) }

      before(:each) do
        dos = PeopleDataService.default_options
        dos[:base_uri] = nil
        PeopleDataService.class_variable_set(:@@default_options, dos)
      end

      it 'raises a suitable error' do
        expect { subject.store_status(status) }.to raise_error StorageError
      end
    end
  end
end
