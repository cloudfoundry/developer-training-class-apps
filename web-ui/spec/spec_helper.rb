# frozen_string_literal: true

$LOAD_PATH << File.expand_path('app')

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, /roster-app.example.com/)
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: File.read('spec/fixtures/people.json'), headers: {})
    stub_request(:post, /myuaa-app.cfapps.io/)
      .with(
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        body: 'token=abc123', basic_auth: %w[oauth_showcase_authorization_code secret]
      )
      .to_return(status: 200, body: File.read('spec/fixtures/check_token_success.json'), headers: {})
    stub_request(:post, /myuaa-app.cfapps.io/)
      .with(
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        body: 'token=invalid', basic_auth: %w[oauth_showcase_authorization_code secret]
      )
      .to_return(status: 401, body: File.read('spec/fixtures/check_token_failure.json'), headers: {})
  end
end
