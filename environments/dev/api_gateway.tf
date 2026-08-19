resource "aws_apigatewayv2_api" "transactions" {
  name          = "financial-sre-dev-transactions-api"
  protocol_type = "HTTP"

  tags = {
    Project     = "financial-sre-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_apigatewayv2_integration" "transaction_api" {
  api_id = aws_apigatewayv2_api.transactions.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.transaction_api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_transaction" {
  api_id = aws_apigatewayv2_api.transactions.id

  route_key = "POST /transactions"
  target    = "integrations/${aws_apigatewayv2_integration.transaction_api.id}"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id = aws_apigatewayv2_api.transactions.id

  name        = "$default"
  auto_deploy = true

  tags = {
    Project     = "financial-sre-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transaction_api.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.transactions.execution_arn}/*/*"
}