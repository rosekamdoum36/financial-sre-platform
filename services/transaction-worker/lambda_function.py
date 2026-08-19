import json
import os
from datetime import datetime, timezone

import boto3


dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["TRANSACTIONS_TABLE"]
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):

    print(
        json.dumps(
            {
                "event_type": "worker_invocation",
                "message_count": len(event.get("Records", [])),
            }
        )
    )

    for record in event.get("Records", []):

        try:
            transaction = json.loads(record["body"])

            transaction_id = transaction["transaction_id"]
            customer_id = transaction["customer_id"]
            amount = transaction["amount"]
            currency = transaction["currency"]

            print(
                json.dumps(
                    {
                        "event_type": "transaction_processing",
                        "transaction_id": transaction_id,
                    }
                )
            )

            table.put_item(
                Item={
                    "transaction_id": transaction_id,
                    "customer_id": customer_id,
                    "amount": str(amount),
                    "currency": currency,
                    "status": "PROCESSED",
                    "processed_at": datetime.now(timezone.utc).isoformat(),
                }
            )

            print(
                json.dumps(
                    {
                        "event_type": "transaction_processed",
                        "transaction_id": transaction_id,
                        "status": "PROCESSED",
                    }
                )
            )

        except Exception as error:

            print(
                json.dumps(
                    {
                        "event_type": "transaction_processing_failed",
                        "error": str(error),
                        "record": record.get("body"),
                    }
                )
            )

            raise

    return {
        "statusCode": 200,
        "body": json.dumps("Transactions processed successfully"),
    }