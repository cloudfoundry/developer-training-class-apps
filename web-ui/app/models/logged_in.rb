# frozen_string_literal: true

require 'oauth2'
require 'base64'
require 'json'

# A class determining the logged in state for a user
class LoggedIn
  def check_token(request)
    client_name = uaa_token_service_client
    client_secret = uaa_token_service_secret
    url = uaa_token_service_url
    return false if url.nil? || client_name.nil? || client_secret.nil?

    auth_token = request.env['HTTP_X_AUTH_TOKEN']
    return false if auth_token.nil?

    validate_token(auth_token, client_name, client_secret, url)
  end

  def message
    if name.nil?
      'Browsing anonymously'
    else
      "Logged in as #{name}"
    end
  end

  attr_reader :name

  private

  def validate_token(auth_token, client_name, client_secret, url)
    client = OAuth2::Client.new(client_name, client_secret, site: url)
    token = OAuth2::AccessToken.new(client, auth_token, mode: :body, param_name: 'token')
    enc   = Base64.encode64("#{client_name}:#{client_secret}")
    begin
      response = token.post('/check_token', headers: { 'Authorization' => "Basic #{enc}" })
    rescue StandardError
      return false
    end
    @name = JSON.parse(response.body)['user_name']
    true
  end
end

def vcap_services
  ENV.fetch('VCAP_SERVICES', nil)
end

def uaa_token_service_url
  uaa_token_creds ? uaa_token_creds['url'] : nil
end

def uaa_token_service_client
  uaa_token_creds ? uaa_token_creds['client_name'] : nil
end

def uaa_token_service_secret
  uaa_token_creds ? uaa_token_creds['client_secret'] : nil
end

def uaa_token_creds
  return nil if vcap_services.nil?
  
  json = JSON.parse(vcap_services)
  service_array = json['user-provided']
  cf_service = service_array.select do |service|
    service['name'].start_with?('uaa-token')
  end.first
  cf_service ? cf_service['credentials'] : nil
end
