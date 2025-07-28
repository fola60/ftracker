from dotenv import load_dotenv
from openai import OpenAI
from DataModels import StatementExtraction, Expenses, Incomes, RecurringRevenues, RecurringCharges, ResponseType, \
    RecurringRevenueResponse, IncomeResponse, Response, RecurringChargeResponse, ExpenseResponse
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
                "content": "Analyze if the text describes a income, expense, recurring expense, or recurring revenue."
            },
            {"role": "user", "content": user_input}
        ]
        ,
        response_format=StatementExtraction
    )
    result = response.choices[0].message.parsed
    print("Statement Extraction: ", result, "\n\n")
    return result

# Parses a StatementExtraction Object into an expense
def parse_finance_expense(statementExtraction: StatementExtraction) -> Expenses:
    response = client.beta.chat.completions.parse(
        model="gpt-4.1-mini",
        messages=[
            {
                "role": "system",
                "content": "Extract detailed information about all expense(s) mentioned in the text. Only include costs."
            },
            {"role": "user", "content": statementExtraction.description}
        ]
        ,
        response_format=Expenses
    )

    result = response.choices[0].message.parsed
    return result


def parse_finance_income(statementExtraction: StatementExtraction, ) -> Incomes:
    response = client.beta.chat.completions.parse(
        model="gpt-4.1-mini",
        messages=[
            {
                "role": "system",
                "content": "Extract detailed information about all income(s) mentioned in the text."
            },
            {"role": "user", "content": statementExtraction.description}
        ]
        ,
        response_format=Incomes
    )


    result = response.choices[0].message.parsed
    return result

def add_recurring_revenue(description: str) -> RecurringRevenues:
    response = client.beta.chat.completions.parse(
        model="gpt-4.1-mini",
        messages=[
            {
                "role": "system",
                "content": "Extract the recurring revenue(s) details."
            },
            {"role": "user", "content": description}
        ]
        ,
        response_format=RecurringRevenues
    )

    return response.choices[0].message.parsed

def add_recurring_expense(description: str) -> RecurringCharges:
    response = client.beta.chat.completions.parse(
        model="gpt-4.1-mini",
        messages=[
            {
                "role": "system",
                "content": "Extract the recurring charge(s) details."
            },
            {"role": "user", "content": description}
        ]
        ,
        response_format=RecurringCharges
    )

    return response.choices[0].message.parsed

def process_finance_request(user_request: str) -> list[Response]:
    responses: list[Response] = []
    extracted_info = extract_finance_info(user_request)

    if extracted_info.is_income:
        parsed_income = parse_finance_income(extracted_info)
        incomeResponse = IncomeResponse(success=True, type=ResponseType.INCOME, income=parsed_income)
        responses.append(incomeResponse)

    if extracted_info.is_recurring_revenue:
        parsed_recurring_revenue = add_recurring_revenue(extracted_info.description)
        recurringRevenueResponse = RecurringRevenueResponse(success=True, type=ResponseType.RECURRING_REVENUE, recurringRevenue=parsed_recurring_revenue)
        responses.append(recurringRevenueResponse)


    if extracted_info.is_expense:
        parsed_expense = parse_finance_expense(extracted_info)
        expenseResponse = ExpenseResponse(success=True, type=ResponseType.EXPENSE, expense=parsed_expense)
        responses.append(expenseResponse)

    if extracted_info.is_recurring_expense:
        parsed_recurring_expense = add_recurring_expense(extracted_info.description)
        recurringChargeResponse = RecurringChargeResponse(success=True, type=ResponseType.RECURRING_CHARGE, recurringCharge=parsed_recurring_expense)
        responses.append(recurringChargeResponse)



    if not extracted_info.is_income and not extracted_info.is_expense and not extracted_info.is_recurring_expense and not extracted_info.is_recurring_revenue:
        return [Response(success="False", error_message="Sorry, we cannot help you with that.", type=ResponseType.ERROR)]

    return responses




