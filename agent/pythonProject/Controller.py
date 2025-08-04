from typing import Union
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from DataModels import Response, TransactionResponse, BudgetResponse, InfoResponse, StatementType, FinanceRequest
from workflow import process_finance_request
from CRUD import verify

app = FastAPI()

ResponseUnion = Union[Response, TransactionResponse, BudgetResponse, InfoResponse]
items = []

class Item(BaseModel):
    text: str = None
    isDone: bool = False


@app.post("/finance-request", response_model = list[Union[ResponseUnion]])
def extract_finance_statements(payload: FinanceRequest):
    if not verify(payload.token):
        null_error_response = [Response(success=False, error_message="Error, restart application.", type=StatementType.ERROR)]
        return null_error_response


    if len(payload.request) < 5:
        null_error_response = [Response(success=False, error_message="Message too short", type=StatementType.ERROR)]
        return null_error_response

    return process_finance_request(payload.request, payload.token, payload.chat_history)
