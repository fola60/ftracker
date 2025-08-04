import json
import datetime
from dotenv import load_dotenv
from openai import OpenAI
from pydantic import BaseModel
import os
from DataModels import Response, StatementType, InfoResponse, BudgetResponse, TransactionResponse, StatementExtraction
from CRUD import TOOLS, call_function, extract_user_id_from_jwt


load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_KEY"))


SYSTEM_PROMPT = "You are a helpful assistant for our money tracking and budgeting app."
MODEL = os.getenv("OPENAI_MODEL_NAME")
MAX_FUNC_CALL = 5
# -----------+
# Functions:
# -----------+

# Validates finance info and returns it in StatementExtraction object
def extract_finance_info(user_input: str, chat_history: list[str]) -> StatementExtraction:
    history_string = "\n".join([f"{msg}" for msg in chat_history])
    response = client.beta.chat.completions.parse(
        model="gpt-4.1-mini",
        messages=[
            {
                "role": "system",
                "content": "You are a helpful assistant for our money tracking and budgeting app. Analyze if the text contains actions to create, update, delete or save a transaction, recurring transaction, a budget or whether the user wants information related to the budgeting app. Extract each action/request that is in the statement."
            },
            {"role": "system", "content": f"Chat history: \n{history_string}"},
            {"role": "user", "content": user_input}
        ]
        ,
        response_format=StatementExtraction
    )
    result = response.choices[0].message.parsed
    print("Statement Extraction: ", result, "\n\n")
    return result


def get_finance_info(description: str, token: str, chat_history: list[str]) -> InfoResponse:
    user_id = extract_user_id_from_jwt(token)
    history_string = "\n".join([f"{msg}" for msg in chat_history])
    print(history_string)
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "system", "content": f"Previous chat history \n{history_string}"},
        {"role": "system", "content": f"user id: {user_id}"},
        {"role": "system", "content": f"The users JWT token is: {token}"},
        {"role": "system", "content": f"Today's date: {datetime.date.today()}"},
        {"role": "user", "content" : description},
    ]

    completion1 = client.chat.completions.create(
        model=MODEL,
        messages=messages,
        tools=TOOLS
    )

    tool_call_length = 0
    if completion1.choices[0].message.tool_calls:
        tool_call_length = len(completion1.choices[0].message.tool_calls)

    count = 0
    while tool_call_length and count < MAX_FUNC_CALL:
        messages.append(completion1.choices[0].message)

        for tool_call in completion1.choices[0].message.tool_calls:
            name = tool_call.function.name
            args = json.loads(tool_call.function.arguments)

            result = call_function(name, **args)

            print(f"function name: {name} args: {args}")

            if isinstance(result, list):
                result = [item.model_dump(mode="json") if isinstance(item, BaseModel) else item for item in result]
            elif isinstance(result, BaseModel):
                result = result.model_dump(mode="json")

            messages.append(
                {"role": "tool", "tool_call_id": tool_call.id, "content": json.dumps(result)}
            )

        completion1 = client.chat.completions.create(
            model=MODEL,
            messages=messages,
            tools=TOOLS
        )

        tool_call_length = len(completion1.choices[0].message.tool_calls or [])
        count += 1


    completion_2 = client.beta.chat.completions.parse(
        model=MODEL,
        messages=messages,
        response_format=InfoResponse
    )
    final_response = completion_2.choices[0].message.parsed
    return final_response

def complete_budget_action(description: str, token: str, chat_history: list[str]) -> BudgetResponse:
    user_id = extract_user_id_from_jwt(token)
    history_string = "\n".join([f"{msg}" for msg in chat_history])
    print(history_string)
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "system", "content": f"user id: {user_id}"},
        {"role": "system", "content": f"Previous chat history \n{history_string}"},
        {"role": "system", "content": f"The users JWT token is: {token}"},
        {"role": "system", "content": f"Today's date: {datetime.date.today()}"},
        {"role": "user", "content": description},
    ]

    completion1 = client.chat.completions.create(
        model=MODEL,
        messages=messages,
        tools=TOOLS
    )

    tool_call_length = 0
    if completion1.choices[0].message.tool_calls:
        tool_call_length = len(completion1.choices[0].message.tool_calls)

    count = 0
    while tool_call_length and count < MAX_FUNC_CALL:
        # Append the assistant's tool_call message once
        messages.append(completion1.choices[0].message)

        # Respond to each tool_call
        for tool_call in completion1.choices[0].message.tool_calls:
            name = tool_call.function.name
            args = json.loads(tool_call.function.arguments)

            result = call_function(name, **args)

            print(f"function name: {name} args: {args}")

            if isinstance(result, list):
                result = [item.model_dump(mode="json") if isinstance(item, BaseModel) else item for item in result]
            elif isinstance(result, BaseModel):
                result = result.model_dump(mode="json")

            messages.append(
                {"role": "tool", "tool_call_id": tool_call.id, "content": json.dumps(result)}
            )

        completion1 = client.chat.completions.create(
            model=MODEL,
            messages=messages,
            tools=TOOLS
        )

        tool_call_length = len(completion1.choices[0].message.tool_calls or [])
        count += 1


    completion_2 = client.beta.chat.completions.parse(
        model=MODEL,
        messages=messages,
        response_format=BudgetResponse
    )
    final_response = completion_2.choices[0].message.parsed
    return final_response


def complete_transaction_action(description: str, token: str, chat_history: list[str]) -> TransactionResponse:
    user_id = extract_user_id_from_jwt(token)
    history_string = "\n".join([f"{msg}" for msg in chat_history])
    print(history_string)
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "system", "content": f"user id: {user_id}"},
        {"role": "system", "content": f"Previous chat history \n{history_string}"},
        {"role": "system", "content": f"Today's date: {datetime.date.today()}"},
        {"role": "system", "content": f"The users JWT token is: {token}"},
        {"role": "user", "content": description},
    ]

    completion1 = client.chat.completions.create(
        model=MODEL,
        messages=messages,
        tools=TOOLS
    )

    tool_call_length = 0
    if completion1.choices[0].message.tool_calls:
        tool_call_length = len(completion1.choices[0].message.tool_calls)

    count = 0
    while tool_call_length and count < MAX_FUNC_CALL:
        # Append the assistant's tool_call message once
        messages.append(completion1.choices[0].message)

        # Respond to each tool_call
        for tool_call in completion1.choices[0].message.tool_calls:
            name = tool_call.function.name
            args = json.loads(tool_call.function.arguments)

            result = call_function(name, **args)

            print(f"function name: {name} args: {args}")

            if isinstance(result, list):
                result = [item.model_dump(mode="json") if isinstance(item, BaseModel) else item for item in result]
            elif isinstance(result, BaseModel):
                result = result.model_dump(mode="json")

            messages.append(
                {"role": "tool", "tool_call_id": tool_call.id, "content": json.dumps(result)}
            )

        completion1 = client.chat.completions.create(
            model=MODEL,
            messages=messages,
            tools=TOOLS
        )

        tool_call_length = len(completion1.choices[0].message.tool_calls or [])
        count += 1

    completion_2 = client.beta.chat.completions.parse(
        model=MODEL,
        messages=messages,
        response_format=TransactionResponse
    )
    final_response = completion_2.choices[0].message.parsed
    return final_response

def process_finance_request(user_request: str, token: str, chat_history: list[str]) -> list[Response]:
    extracted_statements = extract_finance_info(user_request, chat_history)
    responses = []
    if not extracted_statements.is_finance_statement:
        return [Response(success=False, error_message="Sorry, I can only answer questions in relation to our application.", type=StatementType.ERROR)]

    for statement in extracted_statements.statements:
        print(f"Statement: {statement}")
        if statement.type == StatementType.INFO:
            if statement.confidence and statement.confidence > 0.7:
                response = get_finance_info(statement.description, token, chat_history)
                responses.append(response)
        elif statement.type == StatementType.BUDGET:
            if statement.confidence and statement.confidence > 0.7:
                response = complete_budget_action(statement.description, token, chat_history)
                responses.append(response)
        elif statement.type == StatementType.TRANSACTION:
            if statement.confidence and statement.confidence > 0.7:
                response = complete_transaction_action(statement.description, token, chat_history)
                responses.append(response)
        elif statement.type == StatementType.ERROR:
            error_response = Response(success=False, error_message=statement.description, type=StatementType.ERROR)
            responses.append(error_response)

    return responses
