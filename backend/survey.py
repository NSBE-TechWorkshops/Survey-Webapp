import os
import time
import uuid
from typing import Optional
from uuid import uuid4

import boto3
from boto3.dynamodb.conditions import Attr
from fastapi import FastAPI, HTTPException
from mangum import Mangum
from pydantic import BaseModel

app = FastAPI()
handler = Mangum(app)

# ---------------------------------------------------------------------------
# Storage.
#
# Workshop mode: DYNAMODB_ENDPOINT points at the DynamoDB container started by
# docker compose, so no AWS account or credentials are needed. On AWS Lambda
# the variable is unset and boto3 talks to real DynamoDB instead.
# ---------------------------------------------------------------------------

TABLE_NAME = os.environ.get("TABLE_NAME", "survey-responses")
DYNAMODB_ENDPOINT = os.environ.get("DYNAMODB_ENDPOINT") or None

# boto3 reads the region from AWS_DEFAULT_REGION, not AWS_REGION, and fails
# with NoRegionError when neither is set. Pass it explicitly so the app starts
# on a machine with no AWS configuration at all. Lambda sets AWS_REGION itself.
AWS_REGION = (
    os.environ.get("AWS_REGION")
    or os.environ.get("AWS_DEFAULT_REGION")
    or "us-east-1"
)

dynamodb = boto3.resource(
    "dynamodb", endpoint_url=DYNAMODB_ENDPOINT, region_name=AWS_REGION
)


def ensure_local_table() -> None:
    """Create the table in DynamoDB Local so nobody needs Terraform to start."""
    client = dynamodb.meta.client

    for _ in range(30):
        try:
            client.describe_table(TableName=TABLE_NAME)
            return
        except client.exceptions.ResourceNotFoundException:
            client.create_table(
                TableName=TABLE_NAME,
                KeySchema=[{"AttributeName": "response_id", "KeyType": "HASH"}],
                AttributeDefinitions=[
                    {"AttributeName": "response_id", "AttributeType": "S"}
                ],
                BillingMode="PAY_PER_REQUEST",
            )
            client.get_waiter("table_exists").wait(TableName=TABLE_NAME)
            return
        except Exception:
            # DynamoDB Local is still booting. Wait and try again.
            time.sleep(1)

    raise RuntimeError(f"DynamoDB Local never came up at {DYNAMODB_ENDPOINT}")


if DYNAMODB_ENDPOINT:
    ensure_local_table()

table = dynamodb.Table(TABLE_NAME)


class Question(BaseModel):
    content: str


class QuestionResponse(BaseModel):
    question_id: str
    name: str
    answer: str


# ---------------------------------------------------------------------------
# Already working. Use this to prove your setup is good before writing code.
# ---------------------------------------------------------------------------

@app.get("/health")
def health():
    """Write, read and delete one throwaway row, to prove the table works."""
    check_id = f"healthcheck_{uuid.uuid4()}"

    table.put_item(Item={"response_id": check_id, "note": "connection test"})
    read_back = table.get_item(Key={"response_id": check_id}).get("Item")
    table.delete_item(Key={"response_id": check_id})

    return {
        "ok": read_back is not None,
        "table": table.name,
        "wrote": check_id,
        "read_back": read_back,
    }


@app.get("/")
def root():
    return {"hello": "world"}


# ---------------------------------------------------------------------------
# YOUR TURN. Each item in the table needs a "response_id" (the partition key)
# and a "type" so the different kinds of row can be told apart.
#
#   question row -> {"response_id": ..., "type": "question", "question": ...,
#                    "created_time": ...}
#   answer row   -> {"response_id": ..., "type": "answer", "question_id": ...,
#                    "name": ..., "answer": ..., "created_time": ...}
# ---------------------------------------------------------------------------

@app.post("/create-questions")
async def create_questions(question: Question):
    """Save a new question.

    Generate a unique response_id yourself, e.g. f"question_{uuid4().hex}".
    DynamoDB has no auto-increment. Use table.put_item(Item=...).
    Return the item so the caller learns its id.
    """
    raise HTTPException(status_code=501, detail="Not implemented yet")


@app.get("/get-questions")
async def get_questions():
    """Return every question.

    There is no index, so use table.scan with a FilterExpression on "type".
    Attr is already imported for you. Results come back unordered.
    """
    raise HTTPException(status_code=501, detail="Not implemented yet")


@app.put("/update-question/{response_id}")
async def update_question(response_id: str, question: Question):
    """Change the text of an existing question.

    Either table.put_item with the same key (replaces the whole row), or
    table.update_item with an UpdateExpression (changes one field).
    Note that update_item CREATES the row if the key does not exist.
    """
    raise HTTPException(status_code=501, detail="Not implemented yet")


@app.delete("/delete-questions/{response_id}")
async def delete_question(response_id: str):
    """Delete a question by id.

    table.delete_item(Key=...). It succeeds even if nothing was there.
    """
    raise HTTPException(status_code=501, detail="Not implemented yet")


@app.post("/answer")
async def answer_question(response: QuestionResponse):
    """Save someone's answer, linked to the question it belongs to.

    The answer row needs its own response_id AND a question_id pointing at
    the question. Nothing checks that the question actually exists, because
    DynamoDB has no foreign keys.
    """
    raise HTTPException(status_code=501, detail="Not implemented yet")


@app.get("/results/{question_id}")
async def get_results(question_id: str):
    """Return every answer for one question.

    A scan with a FilterExpression matching BOTH type == "answer" and the
    question_id. Conditions combine with & and each side needs parentheses.
    """
    raise HTTPException(status_code=501, detail="Not implemented yet")
