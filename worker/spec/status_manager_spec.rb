# frozen_string_literal: true

require 'status_manager'
require 'people_data_service'

describe 'Sinatra App' do
  context 'when the services are bound' do
    let(:pds) { PeopleDataService.new('http://example.org') }
    let(:status_manager) { StatusManager.new(pds) }
    let(:people_data) do
      [{
        'uuid' => '1234', 'firstName' => 'foo', 'lastName' => 'bar'
      }, {
        'uuid' => '5678', 'firstName' => 'baz', 'lastName' => 'bray', 'email' => 'test@example.com', 'phoneNumber' => '1234', 'companyName' => 'foo Co.'
      }]
    end

    it 'inserts status data and returns ID of updated person' do
      expect(pds).to receive(:people).and_return(People.new(people_data))
      expect(pds).to receive(:store_status).and_return(true)
      expect(%w[1234 5678]).to include(status_manager.record_random_status)
    end

    it 'raises error when no people data is returned' do
      expect(pds).to receive(:people).and_return(People.new([]))
      expect { status_manager.record_random_status }.to raise_error RuntimeError, 'No people data found'
    end

    it 'raises error when person status cannot be stored' do
      expect(pds).to receive(:people).and_return(People.new(people_data))
      expect(pds).to receive(:store_status).and_return(false)
      expect { status_manager.record_random_status }.to raise_error RuntimeError, 'Unable to store status'
    end
  end
end
