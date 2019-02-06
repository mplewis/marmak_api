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

# Sample pure Lambda function

# Parameters
# ----------
# event: Hash, required
#     API Gateway Lambda Proxy Input Format

#     {
#         "resource": "Resource path",
#         "path": "Path parameter",
#         "httpMethod": "Incoming request's method name"
#         "headers": {Incoming request headers}
#         "queryStringParameters": {query string parameters }
#         "pathParameters":  {path parameters}
#         "stageVariables": {Applicable stage variables}
#         "requestContext": {Request context, including authorizer-returned key-value pairs}
#         "body": "A JSON string of the request payload."
#         "isBase64Encoded": "A boolean flag to indicate if the applicable request payload is Base64-encode"
#     }

#     https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

# context: object, required
#     Lambda Context runtime methods and attributes

# Attributes
# ----------

# context.aws_request_id: str
#      Lambda request ID
# context.client_context: object
#      Additional context when invoked through AWS Mobile SDK
# context.function_name: str
#      Lambda function name
# context.function_version: str
#      Function version identifier
# context.get_remaining_time_in_millis: function
#      Time in milliseconds before function times out
# context.identity:
#      Cognito identity provider context when invoked through AWS Mobile SDK
# context.invoked_function_arn: str
#      Function ARN
# context.log_group_name: str
#      Cloudwatch Log group name
# context.log_stream_name: str
#      Cloudwatch Log stream name
# context.memory_limit_in_mb: int
#     Function memory

# Returns
# ------
# API Gateway Lambda Proxy Output Format: dict
#     'statusCode' and 'body' are required

#     {
#         "isBase64Encoded": true | false,
#         "statusCode": httpStatusCode,
#         "headers": {"headerName": "headerValue", ...},
#         "body": "..."
#     }

#     # api-gateway-simple-proxy-for-lambda-output-format
#     https: // docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html

