import os
from CRUD import verify
from pythonProject.workflow import extract_finance_info
from workflow import process_finance_request

token = os.getenv("TOKEN")

# Define test cases
test_cases = [
    {
        "description": "Valid get_transactions call",
        "function_name": "get_transactions",
        "args": {"token": token, "month_range": -1}
    },
    {
        "description": "Missing token in get_transactions",
        "function_name": "get_transactions",
        "args": {"month_range": -1}
    },
    {
        "description": "Unknown function name",
        "function_name": "non_existent_function",
        "args": {"token": token}
    },
    {
        "description": "Valid create_transaction call",
        "function_name": "create_transaction",
        "args": {
            "token": token,
            "transaction": {
                "amount": 5.0,
                "name": "Test Salary",
                "description": "Monthly salary payment",
                "time": "2025-07-17",
                "time_recurring": 30,
                "transaction_type": "RECURRING_INCOME",
                "user_id": 3,
                "category_id": 101
            }
        }
    },
    {
        "description": "Valid create_budget call",
        "function_name": "create_budget",
        "args": {
            "token": token,
            "transaction": {

                "user_id": 3,
                "name": "new testing budget"
            }
        }
    },
    {
        "description": "Reading budgets",
        "function_name": "read_budgets",
        "args": {
            "token": token,
        }
    },
    {
        "description": "Missing transaction in create_transaction",
        "function_name": "create_transaction",
        "args": {"token": token}
    },
    {
        "description": "Valid get_expense_transactions call",
        "function_name": "get_expense_transactions",
        "args": {"token": token}
    },
    {
        "description": "Valid get_income_transactions call",
        "function_name": "get_income_transactions",
        "args": {"token": token}
    },
    {
        "description": "Valid get_recurring_expense_transactions call",
        "function_name": "get_recurring_expense_transactions",
        "args": {"token": token}
    },
    {
        "description": "Valid get_recurring_income_transactions call",
        "function_name": "get_recurring_income_transactions",
        "args": {"token": token}
    },
    {
        "description": "Valid delete_transaction call",
        "function_name": "delete_transaction",
        "args": {"token": token, "transaction_id": 1}
    },
    {
        "description": "Valid delete_transactions call",
        "function_name": "delete_transactions",
        "args": {"token": token, "transaction_ids": [5, 6]}
    },
    {
        "description": "Missing transaction_ids in delete_transactions",
        "function_name": "delete_transactions",
        "args": {"token": token}
    },
    {
        "description": "Missing budget_id in delete_budget",
        "function_name": "delete_budget",
        "args": {"token": token}
    },
    {
        "description": "Valid read_budgets call",
        "function_name": "read_budgets",
        "args": {"token": token}
    },
    {
        "description": "extract_user_id_from_jwt call",
        "function_name": "extract_user_id_from_jwt",
        "args": {"token": token}
    }
]

# Execute and print test results
""" 
for test in test_cases:
    print(f"Test: {test['description']}")
    result = call_function(test["function_name"], **test["args"])
    print("Result:", result)
    print("-" * 50)
"""

#response = process_finance_request("get my budgets", token)
args = {
    "token" : token
}
response = extract_finance_info("Make a new transaction for my ice cream i bought for 8 euro.", [])
print(response)


