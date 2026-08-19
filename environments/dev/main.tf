resource "aws_dynamodb_table" "transactions" {
  name         = "financial-sre-dev-transactions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "transaction_id"

  attribute {
    name = "transaction_id"
    type = "S"
  }

  tags = {
    Project     = "financial-sre-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
resource "aws_sqs_queue" "transaction_dlq" {
  name = "financial-sre-dev-transaction-dlq"

  message_retention_seconds = 1209600

  tags = {
    Project     = "financial-sre-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_sqs_queue" "transaction_queue" {
  name = "financial-sre-dev-transaction-queue"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.transaction_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Project     = "financial-sre-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}