# INC-001 — Transaction Worker DynamoDB Access Denied

## Summary

The transaction API continued accepting customer transactions, but the
transaction worker was unable to persist transactions to DynamoDB.

## Impact

Customer requests were successfully accepted by the API with HTTP 202,
but downstream transaction processing failed.

Affected transactions could not reach the PROCESSED state.

## Detection

The incident was detected by the CloudWatch alarm:

financial-sre-dev-worker-errors

The alarm entered the ALARM state after the Lambda Errors metric crossed
the configured threshold.

Observed error count:

2 errors during the evaluation period.

## Investigation

The transaction API remained operational and continued returning:

202 ACCEPTED

The transaction worker CloudWatch logs were reviewed.

The logs contained:

AccessDeniedException when calling the PutItem operation

This showed that:

- SQS successfully delivered the transaction.
- Lambda successfully invoked the worker.
- The worker reached the DynamoDB write operation.
- DynamoDB rejected the PutItem request because of insufficient IAM permissions.

## Root Cause

The transaction worker IAM policy was missing:

dynamodb:PutItem

As a result, the Lambda execution role did not have permission to write
new transaction records to the DynamoDB transactions table.

## Recovery

The required permission was restored through Terraform:

dynamodb:PutItem

Terraform was validated and the IAM policy change was applied.

## Validation

A new financial transaction was submitted through:

POST /transactions

The API returned:

ACCEPTED

The transaction was subsequently verified in DynamoDB with:

status = PROCESSED

This confirmed successful service recovery.

## Preventive Actions

- Maintain least-privilege IAM policies through Terraform.
- Review IAM policy changes before deployment.
- Add automated validation for critical application permissions.
- Monitor Lambda processing errors.
- Monitor SQS queue backlog and message age.
- Monitor the transaction DLQ.
- Maintain an incident response runbook for transaction processing failures.

## Lessons Learned

A healthy customer-facing API does not guarantee successful downstream
transaction processing.

End-to-end reliability monitoring must include the API, queue, worker,
database, and business transaction state.