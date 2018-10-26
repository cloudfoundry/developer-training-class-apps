# frozen_string_literal: true

require 'controllers/application_controller'
require 'rack/test'

describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    ApplicationController.new
  end

  context 'when the services are bound' do
    def vcap_services
      File.read('spec/fixtures/vcap_services.json')
    end

    before(:each) do
      ENV['VCAP_SERVICES'] = vcap_services
    end

    context 'when browsing anonymously' do
      it 'displays home page' do
        get '/'
        expect(last_response.body).to include('Welcome to People Viewer')
      end

      it 'displays cascade page' do
        get '/cascade'
        expect(last_response.body).to include('Welcome to the Cascading Failure People Viewer')
        expect(last_response.body).to include('with failure')
        expect(last_response.body).to include('without failure')
      end

      it 'displays people data correctly on /people' do
        get '/people'
        expect(last_response.ok?).to be_truthy
        expect(last_response.body).to include('Browsing anonymously')
        expect(last_response.body).to include('foo')
        expect(last_response.body).to include('baz')
      end

      it 'displays people data correctly on /people-safe' do
        get '/people-safe'
        expect(last_response.ok?).to be_truthy
        expect(last_response.body).to include('Browsing anonymously')
        expect(last_response.body).to include('foo')
        expect(last_response.body).to include('baz')
      end

      it 'rejects requests without tokens on the /secure endpoint' do
        get '/secure'
        expect(last_response.status).to eq(401)
      end
    end

    context 'when browsing with valid token' do
      let(:auth_token) { 'abc123' }
      it 'authenticates requests on the /secure endpoint' do
        get '/secure', {}, 'HTTP_X_AUTH_TOKEN' => auth_token
        expect(last_response.ok?).to be_truthy
        expect(last_response.body).to include('You are secure! Logged in as marissa')
      end

      it 'displays home page' do
        get '/', {}, 'HTTP_X_AUTH_TOKEN' => auth_token
        expect(last_response.ok?).to be_truthy
        expect(last_response.body).to include('Logged in as marissa')
        expect(last_response.body).to include('Welcome to People Viewer')
      end

      it 'displays people data correctly on /people' do
        get '/people', {}, 'HTTP_X_AUTH_TOKEN' => auth_token
        expect(last_response.ok?).to be_truthy
        expect(last_response.body).to include('Logged in as marissa')
        expect(last_response.body).to include('foo')
        expect(last_response.body).to include('baz')
      end

      it 'displays people data correctly on /people-safe' do
        get '/people', {}, 'HTTP_X_AUTH_TOKEN' => auth_token
        expect(last_response.ok?).to be_truthy
        expect(last_response.body).to include('Logged in as marissa')
        expect(last_response.body).to include('foo')
        expect(last_response.body).to include('baz')
      end
    end

    context 'when browsing with invalid token' do
      let(:auth_token) { 'invalid' }
      it 'rejects requests on the /secure endpoint' do
        get '/secure', {}, 'HTTP_X_AUTH_TOKEN' => auth_token
        expect(last_response.status).to eq(401)
      end
    end
  end

  context 'when only the rest backend service is  bound' do
    let(:vcap_services) { File.read('spec/fixtures/rest_backend_vcap_services.json') }

    before(:each) do
      ENV['VCAP_SERVICES'] = vcap_services
    end

    it 'displays home page' do
      get '/'
      expect(last_response.body).to include('Welcome to People Viewer')
      expect(last_response.body).to include('Browsing anonymously')
    end

    it 'fails to display /people' do
      get '/people'
      expect(last_response.ok?).to be_truthy
      expect(last_response.body).to include('Browsing anonymously')
    end

    it 'rejects requests on the /secure endpoint' do
      get '/secure'
      expect(last_response.status).to eq(401)
    end
  end

  context 'when the services are not bound' do
    before(:each) do
      ENV['VCAP_SERVICES'] = nil
    end

    it 'displays home page' do
      get '/'
      expect(last_response.body).to include('Welcome to People Viewer')
    end

    it 'fails to display /people' do
      get '/people'
      expect(last_response.ok?).to be_falsy
    end

    it 'rejects requests on the /secure endpoint' do
      get '/secure'
      expect(last_response.status).to eq(401)
    end
  end

  context 'when the rest backend is configured but unavailable' do
    let(:vcap_services) { File.read('spec/fixtures/vcap_services.json') }

    before(:each) do
      ENV['VCAP_SERVICES'] = vcap_services
      stub_request(:get, /roster-app.example.com/)
        .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
        .to_return(status: 500)
    end

    it 'returns an internal server error on /people' do
      get '/people'
      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Backtrace')
    end

    it 'degrades gracefully on /people-safe' do
      get '/people-safe'
      expect(last_response.status).to eq(503)
      expect(last_response.body).to include('The rest data service is currently unavailable')
    end
  end
end

describe 'ApplicationController methods' do
  context 'when the service is bound' do
    let(:vcap_services) { File.read('spec/fixtures/vcap_services.json') }
    it 'gets the rest service URL' do
      ENV['VCAP_SERVICES'] = vcap_services
      expect(rest_backend_url).to eq('http://roster-app.example.com')
    end

    it 'gets the uaa token url' do
      ENV['VCAP_SERVICES'] = vcap_services
      expect(uaa_token_service_url).to eq('https://myuaa-app.cfapps.io')
    end

    it 'gets the uaa client name' do
      ENV['VCAP_SERVICES'] = vcap_services
      expect(uaa_token_service_client).to eq('oauth_showcase_authorization_code')
    end

    it 'gets the uaa client secret' do
      ENV['VCAP_SERVICES'] = vcap_services
      expect(uaa_token_service_secret).to eq('secret')
    end
  end

  context 'when no service is bound' do
    it 'returns nil' do
      ENV['VCAP_SERVICES'] = nil
      expect(rest_backend_url).to be_nil
    end
  end
end
