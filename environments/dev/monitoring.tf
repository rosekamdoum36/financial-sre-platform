resource "aws_cloudwatch_metric_alarm" "worker_errors" {
  alarm_name        = "financial-sre-dev-worker-errors"
  alarm_description = "Alerts when the transaction worker Lambda reports processing errors."

  namespace   = "AWS/Lambda"
  metric_name = "Errors"

  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    FunctionName = aws_lambda_function.transaction_worker.function_name
  }

  treat_missing_data = "notBreaching"

  tags = {
    Project     = "financial-sre-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
resource "aws_cloudwatch_metric_alarm" "transaction_queue_depth" {
  alarm_name        = "financial-sre-dev-transaction-queue-depth"
  alarm_description = "Alerts when transactions accumulate in the processing queue."

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"

  statistic          = "Average"
  period             = 60
  evaluation_periods = 2

  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    QueueName = aws_sqs_queue.transaction_queue.name
  }

  treat_missing_data = "notBreaching"

  tags = {
    Project     = "financial-sre-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
resource "aws_cloudwatch_metric_alarm" "transaction_queue_age" {
  alarm_name        = "financial-sre-dev-transaction-queue-age"
  alarm_description = "Alerts when a transaction remains unprocessed in the queue for too long."

  namespace   = "AWS/SQS"
  metric_name = "ApproximateAgeOfOldestMessage"

  statistic          = "Maximum"
  period             = 60
  evaluation_periods = 2

  threshold           = 120
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    QueueName = aws_sqs_queue.transaction_queue.name
  }

  treat_missing_data = "notBreaching"

  tags = {
    Project     = "financial-sre-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
resource "aws_cloudwatch_metric_alarm" "transaction_dlq_messages" {
  alarm_name        = "financial-sre-dev-transaction-dlq-messages"
  alarm_description = "Alerts when failed financial transaction messages enter the DLQ."

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"

  statistic          = "Average"
  period             = 60
  evaluation_periods = 1

  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    QueueName = aws_sqs_queue.transaction_dlq.name
  }

  treat_missing_data = "notBreaching"

  tags = {
    Project     = "financial-sre-platform"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}