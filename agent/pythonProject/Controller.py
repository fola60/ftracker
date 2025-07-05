from typing import Union
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from DataModels import Response, ResponseType, IncomeResponse, ExpenseResponse, RecurringChargeResponse, RecurringRevenueResponse
from statement_parse import process_finance_request

app = FastAPI()

ResponseUnion = Union[Response, IncomeResponse, ExpenseResponse, RecurringChargeResponse, RecurringRevenueResponse]
items = []

class Item(BaseModel):
    text: str = None
    isDone: bool = False

@app.get("/")
def root():
    return {"Hello": "World"}

@app.post("/items", response_model=list[Item])
def create_item(item: Item) -> list[Item]:
    items.append(item)
    return items

@app.get("/items")
def list_items(limit: int = 10):
    return items[0: limit]

@app.get("/items/{item_id}", response_model=Item)
def get_item(item_id: int) -> Item:
    if item_id < len(items):
        item = items[item_id]
        return item
    else:
        raise HTTPException(status_code=404, detail="Item not found")


@app.get("/finance-request", response_model = list[Union[ResponseUnion]])
def extract_finance_statements(request:str):
    if len(request) < 5:
        null_error_response = [Response(success=False, error_message="Message too short", type=ResponseType.ERROR)]
        return null_error_response

    return process_finance_request(request)
