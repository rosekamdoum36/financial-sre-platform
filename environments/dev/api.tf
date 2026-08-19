resource "aws_lambda_function" "transaction_api" {
  function_name = "financial-sre-dev-transaction-api"

  role    = aws_iam_role.transaction_api_role.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.13"

  filename         = "../../services/transaction-api/transaction-api.zip"
  source_code_hash = filebase64sha256("../../services/transaction-api/transaction-api.zip")

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      TRANSACTION_QUEUE_URL = aws_sqs_queue.transaction_queue.url
    }
  }

  tags = {
    Project     = "financial-sre-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}