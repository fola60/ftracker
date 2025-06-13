from dotenv import load_dotenv
from openai import OpenAI
from typing import Optional, Union
from DataModels import StatementExtraction, Expense, Income, RecurringRevenue, RecurringCharge
import os

load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_KEY"))


# -----------+
# Functions:
# -----------+

# Validates finance info and returns it in StatementExtraction object
def extract_finance_info(user_input: str) -> StatementExtraction:

    response = client.beta.chat.completions.parse(
        model="gpt-4.1-mini",
        messages=[
            {
                "role": "system",
                "content": "Analyze if the text describes a income, expense or neither."
            },
            {"role": "user", "content": user_input}
        ]
        ,
        response_format=StatementExtraction
    )
    result = response.choices[0].message.parsed
    print(result)
    return result

# Parses a StatementExtraction Object into an expense
def parse_finance_expense(statementExtraction: StatementExtraction, ) -> Optional[Expense]:
    if statementExtraction.confidence_score >= 0.7:
        response = client.beta.chat.completions.parse(
            model="gpt-4.1-mini",
            messages=[
                {
                    "role": "system",
                    "content": "Extract the expense details."
                },
                {"role": "user", "content": statementExtraction.description}
            ]
            ,
            response_format=Expense
        )
    else:
        return None



    result = response.choices[0].message.parsed
    print(result)
    return result


def parse_finance_income(statementExtraction: StatementExtraction, ) -> Optional[Income]:
    if statementExtraction.confidence_score >= 0.7:
        response = client.beta.chat.completions.parse(
            model="gpt-4.1-mini",
            messages=[
                {
                    "role": "system",
                    "content": "Extract the income details."
                },
                {"role": "user", "content": statementExtraction.description}
            ]
            ,
            response_format=Income
        )
    else:
        return None



    result = response.choices[0].message.parsed
    print(result)
    return result

def add_recurring_revenue(description: str) -> RecurringRevenue:
    response = client.beta.chat.completions.parse(
        model="gpt-4.1-mini",
        messages=[
            {
                "role": "system",
                "content": "Extract the recurring revenue details."
            },
            {"role": "user", "content": description}
        ]
        ,
        response_format=RecurringRevenue
    )

    return response.choices[0].message.parsed

def add_recurring_expense(description: str) -> RecurringCharge:
    response = client.beta.chat.completions.parse(
        model="gpt-4.1-mini",
        messages=[
            {
                "role": "system",
                "content": "Extract the recurring charge details including amount, name, frequency, and description."
            },
            {"role": "user", "content": description}
        ]
        ,
        response_format=RecurringCharge
    )

    return response.choices[0].message.parsed

def process_finance_request(user_request: str) -> Optional[dict]:
    extracted_info = extract_finance_info(user_request)

    if extracted_info.is_income:
        parsed_income = parse_finance_income(extracted_info)
        parsed_recurring_revenue = None

        if extracted_info.is_recurring_revenue:
            parsed_recurring_revenue = add_recurring_revenue(parsed_income.description)
            if parsed_recurring_revenue.amount == 0.0 and parsed_income.amount > 0:
                parsed_recurring_revenue.amount = parsed_income.amount

        return {"income": parsed_income, "recurring_revenue": parsed_recurring_revenue }

    elif extracted_info.is_expense:
        parsed_expense = parse_finance_expense(extracted_info)
        parsed_recurring_expense = None

        if extracted_info.is_recurring_expense:
            parsed_recurring_expense = add_recurring_expense(parsed_expense.description)
            if parsed_recurring_expense.amount == 0.0 and parsed_expense.amount > 0:
                parsed_recurring_expense.amount = parsed_expense.amount

        return {"expense": parsed_expense, "recurring_expense": parsed_recurring_expense }

    else:
        return None

# -------+
# testing
# -------+

query1 = "I got some m and ms for like 2.80 by aldi"
query2 = "dad gives me like 50 every night"
query3 = "i get eggs every week for 5 euro"

request1 = process_finance_request(query1)
request2 = process_finance_request(query2)
request3 = process_finance_request(query3)

print("Request 1", request1)
print("Request 2", request2)
print("Request 3", request3)
