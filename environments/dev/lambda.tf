resource "aws_lambda_function" "transaction_worker" {
  function_name = "financial-sre-dev-transaction-worker"

  role    = aws_iam_role.transaction_worker_role.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.13"

  filename         = "../../services/transaction-worker/transaction-worker.zip"
  source_code_hash = filebase64sha256("../../services/transaction-worker/transaction-worker.zip")

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      TRANSACTIONS_TABLE = aws_dynamodb_table.transactions.name
    }
  }

  tags = {
    Project     = "financial-sre-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
resource "aws_lambda_event_source_mapping" "transaction_queue_trigger" {
  event_source_arn = aws_sqs_queue.transaction_queue.arn
  function_name    = aws_lambda_function.transaction_worker.arn

  batch_size = 1
  enabled    = true
}