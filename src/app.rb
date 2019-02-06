require 'json'
require_relative 'configurator'

def errors(code, errors)
  { statusCode: code, body: { errors: errors }.to_json }
end

def bad_request(*e)
  errors 400, e
end

def lambda_handler(event:, context:)
  body = JSON.parse event['body']
  params = body['params']
  return bad_request 'Missing key `params`' unless params
  return bad_request "Expected `params` to be a hash, got #{params.class}" unless params.is_a? Hash

  begin
    output = Configurator.generate params
  rescue Configurator::InvalidParamsError => e
    return bad_request e.message
  end

  { statusCode: 200, body: { configuration_h: output }.to_json }
end
