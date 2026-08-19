# Runbook — Transaction Processing Failure

## Purpose

Use this runbook when financial transactions are being accepted by the
Transaction API but are delayed, failing during processing, or entering
the dead-letter queue.

---

## System Flow

Customer
→ API Gateway
→ Transaction API Lambda
→ SQS Transaction Queue
→ Transaction Worker Lambda
→ DynamoDB

Failed messages may be moved to:

SQS Dead-Letter Queue (DLQ)

---

## Relevant Alerts

- financial-sre-dev-worker-errors
- financial-sre-dev-transaction-queue-depth
- financial-sre-dev-transaction-queue-age
- financial-sre-dev-transaction-dlq-messages

---

## Step 1 — Assess Customer and Business Impact

Determine:

- Are customers able to submit transactions?
- Is the API returning HTTP 202 ACCEPTED?
- Are transactions reaching PROCESSED?
- When did the problem begin?
- Are all transactions affected or only some?
- Is transaction processing delayed or completely stopped?

Do not assume that HTTP 202 ACCEPTED means the transaction completed.

---

## Step 2 — Check Alarm State

Review the transaction platform alarms.

```bash
aws cloudwatch describe-alarms \
  --alarm-name-prefix financial-sre-dev- \
  --region us-east-1 \
  --query 'MetricAlarms[*].[AlarmName,StateValue,StateReason]' \
  --output table