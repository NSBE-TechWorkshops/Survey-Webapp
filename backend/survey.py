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

table = boto3.resource("dynamodb").Table(
    os.environ.get("TABLE_NAME", "survey-responses")
)


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
