import requests
import base64
import json
from DataModels import Budget, Transaction, TransactionRequestModel, BudgetRequestModel, \
    CategoryRequestModel, Category, BudgetCategoryRequestModel, BudgetCategory
from typing import List, Optional
from datetime import datetime, timedelta

BACKEND_URL = "http://host.docker.internal:8080"

def verify(token: str) -> bool:
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }

    response = requests.get(
        f"{BACKEND_URL}/user/auth/check-token",
        headers=headers
    )

    if response.status_code == 200:
        return True
    else:
        return False

class TransactionRequests:
    backend_url = BACKEND_URL
    @staticmethod
    def create_transaction(token: str, transaction: TransactionRequestModel) -> Optional[Transaction]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        transaction_data = transaction.model_dump(mode="json")

        response = requests.post(
            f"{TransactionRequests.backend_url}/transaction/post",
            json=transaction_data,
            headers=headers
        )

        if response.status_code == 200:
            print("Response json: ")
            print(response.json())
            return Transaction(**response.json())
        else:
            return None

    @staticmethod
    def _filter_transactions_by_month_range(transactions: List[Transaction], month_range: int) -> List[Transaction]:
        """Filter transactions by month range. If month_range is -1, return all transactions."""
        if month_range == -1:
            return transactions

        current_date = datetime.now()
        cutoff_date = current_date - timedelta(days=month_range * 30)  # Approximate months as 30 days

        filtered_transactions = []
        for transaction in transactions:
            try:
                if isinstance(transaction.time, str):
                    transaction_date = datetime.fromisoformat(transaction.time.replace('Z', '+00:00'))
                else:
                    transaction_date = transaction.time

                if transaction_date >= cutoff_date:
                    filtered_transactions.append(transaction)
            except (ValueError, AttributeError):
                # If we can't parse the date, include the transaction to be safe
                filtered_transactions.append(transaction)

        return filtered_transactions

    @staticmethod
    def get_transactions(token: str, month_range: int = -1) -> List[Transaction]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        user_id = extract_user_id_from_jwt(token)

        url = f"{TransactionRequests.backend_url}/transaction/get-all/{user_id}"
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            transactions_data = response.json()
            transactions = [Transaction(**transaction) for transaction in transactions_data]
            return TransactionRequests._filter_transactions_by_month_range(transactions, month_range)
        else:
            return []

    @staticmethod
    def post(token: str, transaction: TransactionRequestModel) -> Optional[Transaction]:
        return Transaction.update_transaction(token, transaction)

    @staticmethod
    def update_transaction(token: str, updated_transaction: TransactionRequestModel) -> Optional[Transaction]:
        return TransactionRequests.create_transaction(token, updated_transaction)

    @staticmethod
    def delete_transaction(token: str, transaction_id: int) -> bool:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }

        response = requests.delete(
            f"{TransactionRequests.backend_url}/transaction/delete/{transaction_id}",
            headers=headers
        )

        return response.status_code == 200


    @staticmethod
    def get_expense_transactions(token: str, month_range: int = -1) -> List[Transaction]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        user_id = extract_user_id_from_jwt(token)
        url = f"{TransactionRequests.backend_url}/transaction/get-all-expenses/{user_id}"
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            transactions_data = response.json()
            transactions = [Transaction(**transaction) for transaction in transactions_data]
            return TransactionRequests._filter_transactions_by_month_range(transactions, month_range)
        else:
            return []

    @staticmethod
    def get_income_transactions(token: str, month_range: int = -1) -> List[Transaction]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        user_id = extract_user_id_from_jwt(token)
        url = f"{TransactionRequests.backend_url}/transaction/get-all-incomes/{user_id}"
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            transactions_data = response.json()
            transactions = [Transaction(**transaction) for transaction in transactions_data]
            return TransactionRequests._filter_transactions_by_month_range(transactions, month_range)
        else:
            return []

    @staticmethod
    def get_recurring_expense_transactions(token: str) -> List[Transaction]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        user_id = extract_user_id_from_jwt(token)
        url = f"{TransactionRequests.backend_url}/transaction/get-all-recurring-expenses/{user_id}"
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            transactions_data = response.json()
            transactions = [Transaction(**transaction) for transaction in transactions_data]
            return transactions
        else:
            return []

    @staticmethod
    def get_recurring_income_transactions(token: str) -> List[Transaction]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        user_id = extract_user_id_from_jwt(token)
        url = f"{TransactionRequests.backend_url}/transaction/get-all-recurring-incomes/{user_id}"
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            transactions_data = response.json()
            transactions = [Transaction(**transaction) for transaction in transactions_data]
            return transactions
        else:
            return []

    @staticmethod
    def create_transactions(token: str, transactions: list[TransactionRequestModel]) -> list[Optional[Transaction]]:
        transactions_list = []
        for transaction in transactions:
            transactions_list.append(TransactionRequests.create_transaction(token, transaction))

        return transactions_list

    @staticmethod
    def delete_transactions(token: str, transaction_ids: list[int]) -> bool:
        for transaction_id in transaction_ids:
            TransactionRequests.delete_transaction(token, transaction_id)
        return True

    @staticmethod
    def update_transactions(token: str, updated_transactions: list[TransactionRequestModel]) -> list[Optional[Transaction]]:
        return TransactionRequests.create_transactions(token, updated_transactions)

class BudgetRequests:
    backend_url = BACKEND_URL
    @staticmethod
    def create_budget(token: str, budget: BudgetRequestModel) -> Optional[Budget]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        budget_data = budget.model_dump(mode="json")

        response = requests.post(
            f"{BudgetRequests.backend_url}/budget/save-budget",
            json=budget_data,
            headers=headers
        )

        if response.status_code == 200:
            return Budget(**response.json())
        else:
            return None

    @staticmethod
    def read_budgets(token: str) -> List[Budget]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        user_id = extract_user_id_from_jwt(token)
        response = requests.get(
            f"{BudgetRequests.backend_url}/budget/get-budget-by-user-id/{user_id}",
            headers=headers
        )

        if response.status_code == 200:
            budgets_data = response.json()
            return [Budget(**budget) for budget in budgets_data]
        else:
            return []

    @staticmethod
    def update_budget(token: str, updated_budget: BudgetRequestModel) -> Optional[Budget]:
        return BudgetRequests.create_budget(token, updated_budget)

    @staticmethod
    def delete_budget(token: str, budget_id: int) -> bool:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }

        response = requests.delete(
            f"{BudgetRequests.backend_url}/budget/delete-budget/{budget_id}",
            headers=headers
        )

        return response.status_code == 200

    @staticmethod
    def add_budget_category(token: str, newBudgetCategoryRequest: BudgetCategoryRequestModel) -> Optional[BudgetCategory]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }

        budget_category_data = newBudgetCategoryRequest.model_dump(mode="json")

        response = requests.post(
            f"{CategoryRequests.backend_url}/category/post",
            json=budget_category_data,
            headers=headers
        )

        if response.status_code == 200:
            return BudgetCategory(**response.json())
        else:
            return None

class CategoryRequests:
    backend_url = BACKEND_URL

    @staticmethod
    def create_category(token: str, new_category: CategoryRequestModel) -> Optional[Category]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        category_data = new_category.model_dump(mode="json")

        response = requests.post(
            f"{CategoryRequests.backend_url}/category/post",
            json=category_data,
            headers=headers
        )

        if response.status_code == 200:
            return Category(**response.json())
        else:
            return None

    @staticmethod
    def get_all_category_by_id(token: str) -> list[Category]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        user_id = extract_user_id_from_jwt(token)

        url = f"{CategoryRequests.backend_url}/category/get-by-user-id/{user_id}"
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            categories_data = response.json()
            categories = [Category(**category) for category in categories_data]
            return categories
        else:
            return []

    @staticmethod
    def delete_category(token: str, category_id: int) -> bool:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }

        response = requests.delete(
            f"{CategoryRequests.backend_url}/category/delete/{category_id}",
            headers=headers
        )

        return response.status_code == 200


def extract_user_id_from_jwt(token: str) -> Optional[int]:
    try:
        segments = token.split(".")
        if len(segments) != 3:
            return None

        payload_segment = segments[1]

        # Pad base64 string if needed
        rem = len(payload_segment) % 4
        if rem > 0:
            payload_segment += "=" * (4 - rem)

        # Replace URL-safe characters
        payload_segment = payload_segment.replace('-', '+').replace('_', '/')

        # Decode and parse JSON
        decoded_bytes = base64.b64decode(payload_segment)
        decoded_json = json.loads(decoded_bytes.decode('utf-8'))

        # Extract "sub" and convert to int
        sub = decoded_json.get("sub")
        if sub is not None:
            return int(sub)

        return None
    except (ValueError, json.JSONDecodeError, base64.binascii.Error):
        return None

TOOLS = [
    # Transaction Functions
    {
        "type": "function",
        "function": {
            "name": "create_transaction",
            "description": "Create a new transaction",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "transaction": {
                        "type": "object",
                        "description": "Transaction request model",
                        "properties": {
                            "amount": {"type": "number", "description": "Amount of transaction"},
                            "name": {"type": "string", "description": "Summarised name of the transaction e.g. monthly salary"},
                            "description": {"type": "string", "description": "Details of the transaction"},
                            "time": {"type": "string", "description": "The time of the transaction in ISO format"},
                            "time_recurring": {"type": ["integer", "null"], "description": "Time in days the transaction re occurs if its a recurring transaction"},
                            "transaction_type": {"type": "string", "description": "Transaction type: EXPENSE, INCOME, RECURRING_EXPENSE, RECURRING_INCOME"},
                            "user_id": {"type": "integer", "description": "The id of the user"},
                            "category_id": {"type": "integer", "description": "The id of the category of transaction"}
                        },
                        "required": ["amount", "name", "description", "time", "time_recurring", "transaction_type", "user_id", "category_id"],
                        "additionalProperties": False
                    }
                },
                "required": ["token", "transaction"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "create_transactions",
            "description": "Create multiple transactions at once",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "transactions": {
                        "type": "array",
                        "description": "Array of transaction request models",
                        "items": {
                            "type": "object",
                            "properties": {
                                "amount": {"type": "number", "description": "Amount of transaction"},
                                "name": {"type": "string", "description": "Summarised name of the transaction e.g. monthly salary"},
                                "description": {"type": "string", "description": "Details of the transaction"},
                                "time": {"type": "string", "description": "The time of the transaction in ISO format"},
                                "time_recurring": {"type": ["integer", "null"], "description": "Time in days the transaction re occurs if its a recurring transaction"},
                                "transaction_type": {"type": "string", "description": "Transaction type: EXPENSE, INCOME, RECURRING_EXPENSE, RECURRING_INCOME"},
                                "user_id": {"type": "integer", "description": "The id of the user"},
                                "category_id": {"type": "integer", "description": "The id of the category of transaction"}
                            },
                            "required": ["amount", "name", "description", "time", "time_recurring", "transaction_type", "user_id", "category_id"],
                            "additionalProperties": False
                        }
                    }
                },
                "required": ["token", "transactions"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_transactions",
            "description": "Get all transactions for a user, optionally filtered by month range",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "month_range": {"type": "integer", "description": "Number of months to filter by (-1 for all transactions)", "default": -1}
                },
                "required": ["token", "month_range"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "update_transaction",
            "description": "Update an existing transaction",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "updated_transaction": {
                        "type": "object",
                        "description": "Updated transaction request model",
                        "properties": {
                            "amount": {"type": "number", "description": "Amount of transaction"},
                            "name": {"type": "string", "description": "Summarised name of the transaction e.g. monthly salary"},
                            "description": {"type": "string", "description": "Details of the transaction"},
                            "time": {"type": "string", "description": "The time of the transaction in ISO format"},
                            "time_recurring": {"type": ["integer", "null"], "description": "Time in days the transaction re occurs if its a recurring transaction"},
                            "transaction_type": {"type": "string", "description": "Transaction type: EXPENSE, INCOME, RECURRING_EXPENSE, RECURRING_INCOME"},
                            "user_id": {"type": "integer", "description": "The id of the user"},
                            "category_id": {"type": "integer", "description": "The id of the category of transaction"}
                        },
                        "required": ["amount", "name", "description", "time", "time_recurring", "transaction_type", "user_id", "category_id"],
                        "additionalProperties": False
                    }
                },
                "required": ["token", "updated_transaction"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "update_transactions",
            "description": "Update multiple transactions at once",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "updated_transactions": {
                        "type": "array",
                        "description": "Array of updated transaction request models",
                        "items": {
                            "type": "object",
                            "properties": {
                                "amount": {"type": "number", "description": "Amount of transaction"},
                                "name": {"type": "string", "description": "Summarised name of the transaction e.g. monthly salary"},
                                "description": {"type": "string", "description": "Details of the transaction"},
                                "time": {"type": "string", "description": "The time of the transaction in ISO format"},
                                "time_recurring": {"type": ["integer", "null"], "description": "Time in days the transaction re occurs if its a recurring transaction"},
                                "transaction_type": {"type": "string", "description": "Transaction type: EXPENSE, INCOME, RECURRING_EXPENSE, RECURRING_INCOME"},
                                "user_id": {"type": "integer", "description": "The id of the user"},
                                "category_id": {"type": "integer", "description": "The id of the category of transaction"}
                            },
                            "required": ["amount", "name", "description", "time", "time_recurring", "transaction_type", "user_id", "category_id"],
                            "additionalProperties": False
                        }
                    }
                },
                "required": ["token", "updated_transactions"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "delete_transaction",
            "description": "Delete a transaction by ID",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "transaction_id": {"type": "integer", "description": "ID of the transaction to delete"}
                },
                "required": ["token", "transaction_id"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "delete_transactions",
            "description": "Delete multiple transactions by their IDs",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "transaction_ids": {
                        "type": "array",
                        "description": "Array of transaction IDs to delete",
                        "items": {"type": "integer"}
                    }
                },
                "required": ["token", "transaction_ids"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_expense_transactions",
            "description": "Get all expense transactions for a user, optionally filtered by month range",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "month_range": {"type": "integer", "description": "Number of months to filter by (-1 for all transactions)", "default": -1}
                },
                "required": ["token", "month_range"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_income_transactions",
            "description": "Get all income transactions for a user, optionally filtered by month range",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "month_range": {"type": "integer", "description": "Number of months to filter by (-1 for all transactions)", "default": -1}
                },
                "required": ["token", "month_range"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_recurring_expense_transactions",
            "description": "Get all recurring expense transactions for a user, optionally filtered by month range",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                },
                "required": ["token"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_recurring_income_transactions",
            "description": "Get all recurring income transactions for a user, optionally filtered by month range",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                },
                "required": ["token"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    # Budget Functions
    {
        "type": "function",
        "function": {
            "name": "create_budget",
            "description": "Create a new budget",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "budget": {
                        "type": "object",
                        "description": "Budget request model",
                        "properties": {
                            "name": {"type": "string", "description": "The name of the budget"},
                            "user_id": {"type": "integer", "description": "The id of the user this belongs to"}
                        },
                        "required": ["name", "user_id"],
                        "additionalProperties": False
                    }
                },
                "required": ["token", "budget"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "read_budgets",
            "description": "Get all budgets for a user",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"}
                },
                "required": ["token"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "update_budget",
            "description": "Update an existing budget",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "updated_budget": {
                        "type": "object",
                        "description": "Updated budget request model",
                        "properties": {
                            "name": {"type": "string", "description": "The name of the budget"},
                            "user_id": {"type": "integer", "description": "The id of the user this belongs to"}
                        },
                        "required": ["name", "user_id"],
                        "additionalProperties": False
                    }
                },
                "required": ["token", "updated_budget"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "delete_budget",
            "description": "Delete a budget by ID",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "budget_id": {"type": "integer", "description": "ID of the budget to delete"}
                },
                "required": ["token", "budget_id"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    # Category Functions
    {
        "type": "function",
        "function": {
            "name": "create_category",
            "description": "Create a new category",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "new_category": {
                        "type": "object",
                        "description": "Category request model",
                        "properties": {
                            "head_category": {"type": "string", "description": "The head category this category belongs to: ENTERTAINMENT, FOOD_AND_DRINKS, HOUSING, INCOME, LIFESTYLE, MISCELLANEOUS, SAVINGS, TRANSPORTATION"},
                            "name": {"type": "string", "description": "The name of this category"},
                            "user_id": {"type": "integer", "description": "The user id this category belongs to"}
                        },
                        "required": ["head_category", "name", "user_id"],
                        "additionalProperties": False
                    }
                },
                "required": ["token", "new_category"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_all_category_by_id",
            "description": "Get all categories for a user",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"}
                },
                "required": ["token"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "delete_category",
            "description": "Delete a category by ID",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT authentication token"},
                    "category_id": {"type": "integer", "description": "ID of the category to delete"}
                },
                "required": ["token", "category_id"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    {
        "type": "function",
        "function": {
            "name": "add_budget_category",
            "description": "Add a category to a budget with a spending cap. Use get_all_category_by_id to get categories id and if it does not exist create one.",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {
                        "type": "string",
                        "description": "JWT authentication token"
                    },
                    "newBudgetCategoryRequest": {
                        "type": "object",
                        "description": "Data for the new budget category",
                        "properties": {
                            "budget_id": {
                                "type": "integer",
                                "description": "The id of the budget this is being added to."
                            },
                            "amount": {
                                "type": "number",
                                "description": "The monthly cap for this category."
                            },
                            "category_id": {
                                "type": "integer",
                                "description": "The id of the category of this budget"
                            }
                        },
                        "required": ["budget_id", "amount", "category_id"],
                        "additionalProperties": False
                    }
                },
                "required": ["token", "newBudgetCategoryRequest"],
                "additionalProperties": False
            },
            "strict": True
        }
    },
    # Utility Functions
    {
        "type": "function",
        "function": {
            "name": "extract_user_id_from_jwt",
            "description": "Extract user ID from JWT token",
            "parameters": {
                "type": "object",
                "properties": {
                    "token": {"type": "string", "description": "JWT token to extract user ID from"}
                },
                "required": ["token"],
                "additionalProperties": False
            },
            "strict": True
        }
    }
]
def call_function(function_name: str, **kwargs):
    """
    Route function calls to the appropriate TransactionRequest, BudgetRequest, or CategoryRequest method.

    Args:
        function_name (str): Name of the function to call
        **kwargs: Arguments to pass to the function

    Returns:
        Result of the function call or error message
    """

    # Transaction-related functions
    if function_name == "create_transaction":
        if "token" not in kwargs or "transaction" not in kwargs:
            return {"error": "Missing required parameters: token and transaction"}
        model = TransactionRequestModel(**kwargs["transaction"])
        return TransactionRequests.create_transaction(kwargs["token"], model)

    elif function_name == "create_transactions":
        if "token" not in kwargs or "transactions" not in kwargs:
            return {"error": "Missing required parameters: token and transactions"}
        models = [TransactionRequestModel(**tx) for tx in kwargs["transactions"]]
        return TransactionRequests.create_transactions(kwargs["token"], models)

    elif function_name == "get_transactions":
        if "token" not in kwargs:
            return {"error": "Missing required parameter: token"}
        month_range = kwargs.get("month_range", -1)
        return TransactionRequests.get_transactions(kwargs["token"], month_range)

    elif function_name == "update_transaction":
        if "token" not in kwargs or "updated_transaction" not in kwargs:
            return {"error": "Missing required parameters: token and updated_transaction"}
        model = TransactionRequestModel(**kwargs["updated_transaction"])
        return TransactionRequests.update_transaction(kwargs["token"], model)

    elif function_name == "update_transactions":
        if "token" not in kwargs or "updated_transactions" not in kwargs:
            return {"error": "Missing required parameters: token and updated_transactions"}
        models = [TransactionRequestModel(**tx) for tx in kwargs["updated_transactions"]]
        return TransactionRequests.update_transactions(kwargs["token"], models)

    elif function_name == "delete_transaction":
        if "token" not in kwargs or "transaction_id" not in kwargs:
            return {"error": "Missing required parameters: token and transaction_id"}
        return TransactionRequests.delete_transaction(kwargs["token"], kwargs["transaction_id"])

    elif function_name == "delete_transactions":
        if "token" not in kwargs or "transaction_ids" not in kwargs:
            return {"error": "Missing required parameters: token and transaction_ids"}
        return TransactionRequests.delete_transactions(kwargs["token"], kwargs["transaction_ids"])

    elif function_name == "get_expense_transactions":
        if "token" not in kwargs:
            return {"error": "Missing required parameter: token"}
        month_range = kwargs.get("month_range", -1)
        return TransactionRequests.get_expense_transactions(kwargs["token"], month_range)

    elif function_name == "get_income_transactions":
        if "token" not in kwargs:
            return {"error": "Missing required parameter: token"}
        month_range = kwargs.get("month_range", -1)
        return TransactionRequests.get_income_transactions(kwargs["token"], month_range)

    elif function_name == "get_recurring_expense_transactions":
        if "token" not in kwargs:
            return {"error": "Missing required parameter: token"}
        return TransactionRequests.get_recurring_expense_transactions(kwargs["token"])

    elif function_name == "get_recurring_income_transactions":
        if "token" not in kwargs:
            return {"error": "Missing required parameter: token"}
        return TransactionRequests.get_recurring_income_transactions(kwargs["token"])

    # Budget-related functions
    elif function_name == "create_budget":
        if "token" not in kwargs or "budget" not in kwargs:
            return {"error": "Missing required parameters: token and budget"}
        model = BudgetRequestModel(**kwargs["budget"])
        return BudgetRequests.create_budget(kwargs["token"], model)

    elif function_name == "read_budgets":
        if "token" not in kwargs:
            return {"error": "Missing required parameter: token"}
        return BudgetRequests.read_budgets(kwargs["token"])

    elif function_name == "update_budget":
        if "token" not in kwargs or "updated_budget" not in kwargs:
            return {"error": "Missing required parameters: token and updated_budget"}
        model = BudgetRequestModel(**kwargs["updated_budget"])
        return BudgetRequests.update_budget(kwargs["token"], model)

    elif function_name == "delete_budget":
        if "token" not in kwargs or "budget_id" not in kwargs:
            return {"error": "Missing required parameters: token and budget_id"}
        return BudgetRequests.delete_budget(kwargs["token"], kwargs["budget_id"])

    elif function_name == "add_budget_category":
        if "token" not in kwargs or "newBudgetCategoryRequest" not in kwargs:
            return {"error": "Missing required parameters: token and newBudgetCategoryRequest"}
        model = BudgetCategoryRequestModel(**kwargs["newBudgetCategoryRequest"])
        return BudgetRequests.add_budget_category(kwargs["token"], model)

    # Category-related functions
    elif function_name == "create_category":
        if "token" not in kwargs or "new_category" not in kwargs:
            return {"error": "Missing required parameters: token and new_category"}
        model = CategoryRequestModel(**kwargs["new_category"])
        return CategoryRequests.create_category(kwargs["token"], model)

    elif function_name == "get_all_category_by_id":
        if "token" not in kwargs:
            return {"error": "Missing required parameter: token"}
        return CategoryRequests.get_all_category_by_id(kwargs["token"])

    elif function_name == "delete_category":
        if "token" not in kwargs or "category_id" not in kwargs:
            return {"error": "Missing required parameters: token and category_id"}
        return CategoryRequests.delete_category(kwargs["token"], kwargs["category_id"])

    # Utility function
    elif function_name == "extract_user_id_from_jwt":
        if "token" not in kwargs:
            return {"error": "Missing required parameter: token"}
        return extract_user_id_from_jwt(kwargs["token"])

    else:
        return {"error": f"Unknown function: {function_name}"}
