import json
import os
import uuid
from datetime import datetime, timezone

import boto3


sqs = boto3.client("sqs")

QUEUE_URL = os.environ["TRANSACTION_QUEUE_URL"]


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))

        customer_id = body["customer_id"]
        amount = body["amount"]
        currency = body["currency"]

        transaction_id = f"TXN-{uuid.uuid4().hex[:8].upper()}"

        transaction = {
            "transaction_id": transaction_id,
            "customer_id": customer_id,
            "amount": amount,
            "currency": currency,
            "status": "PENDING",
            "created_at": datetime.now(timezone.utc).isoformat(),
        }

        print(
            json.dumps(
                {
                    "event_type": "transaction_received",
                    "transaction_id": transaction_id,
                    "customer_id": customer_id,
                }
            )
        )

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(transaction),
        )

        print(
            json.dumps(
                {
                    "event_type": "transaction_queued",
                    "transaction_id": transaction_id,
                }
            )
        )

        return {
            "statusCode": 202,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(
                {
                    "transaction_id": transaction_id,
                    "status": "ACCEPTED"
                }
            ),
        }

    except KeyError as error:
        return {
            "statusCode": 400,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(
                {
                    "error": f"Missing required field: {str(error)}"
                }
            ),
        }

    except Exception as error:
        print(
            json.dumps(
                {
                    "event_type": "transaction_api_failed",
                    "error": str(error),
                }
            )
        )

        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(
                {
                    "error": "Internal server error"
                }
            ),
        }