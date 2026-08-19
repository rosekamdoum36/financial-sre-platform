output "transaction_api_url" {
  description = "Base URL for the Financial SRE transaction API"
  value       = aws_apigatewayv2_api.transactions.api_endpoint
}