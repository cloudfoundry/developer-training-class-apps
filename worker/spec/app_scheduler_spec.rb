# frozen_string_literal: true

require 'app_scheduler'
require 'status_manager'
RSpec.describe AppScheduler do
  describe 'run method' do
    let(:status_manager) { double('StatusManager') }
    let(:app) { AppScheduler.new(status_manager) }
    after(:each) do
      app.kill
    end

    it 'does the right thing' do
      expect(status_manager).to receive(:record_random_status).at_least(:once).and_return('1234')
      app.run
      sleep 12
    end
  end
end

describe '#rest_backend_url' do
  context 'when VCAP_SERVICES is set' do
    let(:vcap_services) { File.read('spec/fixtures/vcap_services.json') }

    before(:each) do
      ENV['VCAP_SERVICES'] = vcap_services
    end

    it 'returns the rest data service url' do
      expect(rest_backend_url).to eq('http://roster-app.example.com')
    end
  end

  context 'when VCAP_SERVICES is not set' do
    before(:each) do
      ENV['VCAP_SERVICES'] = '{}'
    end

    it 'returns nil' do
      expect(rest_backend_url).to be_nil
    end
  end
end
