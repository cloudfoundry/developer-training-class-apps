# frozen_string_literal: true

$LOAD_PATH << File.expand_path('lib')

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, /roster-app.example.com/)
      .with(headers: { 'Accept' => 'application/hal+json' })
      .to_return(status: 200, body: File.read('spec/fixtures/people.json'), headers: {})
    stub_request(:post, 'http://roster-app.example.com/people_status')
      .with(
        body: '{"status":"Active","updatedTime":"2017-03-10T13:16:36.000+0000","person":"http://roster-app.example.com/people/foo"}',
        headers: { 'Accept' => 'application/hal+json' }
      )
      .to_return(status: 201, body: '', headers: {})
  end
end
