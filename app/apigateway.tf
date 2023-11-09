#resource "aws_lambda_permission" "this" {
#  statement_id  = "AllowExecutionFromAPIGateway"
#  action        = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.this.function_name
#  principal     = "apigateway.amazonaws.com"
#
#  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
#}

# TO FILL IN resources, including but not limited to
# - aws_api_gateway_rest_api
# - aws_api_gateway_method
# - aws_api_gateway_deployment



resource "aws_api_gateway_rest_api" "example" {
  name        = "example-api"
  description = "Example API"
}

resource "aws_api_gateway_resource" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "POST"  # Specify the HTTP method you want to use (e.g., POST, POST)
  authorization = "NONE"
}


resource "aws_lambda_permission" "example" {
  statement_id  = "example"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  integration_http_method = "POST"  # Specify the HTTP method of your Lambda function
  type       = "AWS_PROXY"
  uri        = aws_lambda_function.this.invoke_arn
}

resource "aws_api_gateway_method_response" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"  # You can specify a different response model if needed
  }
}

resource "aws_api_gateway_integration_response" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  status_code = aws_api_gateway_method_response.example.status_code
  
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [aws_api_gateway_integration.example]

  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name = "dev"  # Specify the desired stage name
}


