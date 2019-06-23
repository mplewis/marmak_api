require 'json'
require_relative 'configurator'

def respond(code, body)
  { statusCode: code, body: body.to_json }
end

def bad_request(message)
  respond 400, { message: message }
end

def invalid_params(message, errors)
  respond 400, { message: message, errors: errors }
end

def success(**body)
  respond 200, body
end

def lambda_handler(event:, context:)
  body = JSON.parse event['body']
  params = body['params']
  return bad_request 'Missing key `params`' unless params
  return bad_request "Expected `params` to be a hash, got #{params.class}" unless params.is_a? Hash

  begin
    output = Configurator.generate params
  rescue Configurator::InvalidParamsError => e
    return invalid_params e.message, e.errors
  end

  success configuration_h: output
end
