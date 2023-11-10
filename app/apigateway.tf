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
#  response_models = {
#    "application/json" = "Empty"  # You can specify a different response model if needed
#  }
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


resource "aws_api_gateway_method" "MyDemoMethod" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.ApiProxyResource.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}


resource "aws_api_gateway_resource" "ApiProxyResource" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_integration" "proxyexample" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.ApiProxyResource.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method
  integration_http_method = "POST"  # Specify the HTTP method of your Lambda function
  type       = "AWS_PROXY"
  uri        = aws_lambda_function.this.invoke_arn
}

resource "aws_api_gateway_method_response" "proxy_example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.ApiProxyResource.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method
  status_code = "200"
#  response_models = {
#    "application/json" = "Empty"  # You can specify a different response model if needed
#  }
}


resource "aws_api_gateway_deployment" "proxy_example" {
  depends_on = [aws_api_gateway_integration.proxyexample]
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name = "dev"  # Specify the desired stage name
}

# Apigw key and usage plan

resource "aws_api_gateway_api_key" "this" {
  name = "helloworld-localstack-test"
}

resource "aws_api_gateway_usage_plan" "demo_api_usage_plan" {
  name = "usage-helloworld-localstack-test"

  api_stages {
    api_id = "${aws_api_gateway_rest_api.example.id}"
    stage  = "${aws_api_gateway_deployment.example.stage_name}"
  }
}

resource "aws_api_gateway_usage_plan_key" "demo_api_usage_plan_key" {
  key_id        = "${aws_api_gateway_api_key.this.id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.demo_api_usage_plan.id}"
}


resource "aws_api_gateway_resource" "demo_api_resource_demo" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  path_part   = "demo"
}

resource "aws_api_gateway_method" "demo_api_methods_demo" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_resource.example.id}"
  http_method   = "ANY"
  authorization = "NONE"
  api_key_required = true # <-- only working if deploy is done after API key creation
}







# Custom Domain

resource "aws_api_gateway_domain_name" "example" {
  domain_name              = "helloworld.myapp.earth"
  regional_certificate_arn = aws_acm_certificate_validation.example.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_route53_zone" "example" {
  name = "myapp.earth"
}


resource "aws_acm_certificate" "example" {
  domain_name       = "helloworld.myapp.earth"
  validation_method = "DNS"
}

data "aws_route53_zone" "example" {
  name         = "myapp.earth"
  private_zone = false
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.example.zone_id
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
}
