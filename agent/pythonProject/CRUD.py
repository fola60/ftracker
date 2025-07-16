import requests
import base64
import json
from pythonProject.DataModels import Budget, Transaction
from typing import List, Optional
from datetime import datetime, timedelta
from typing import Any, Callable

class TransactionRequests:
    backend_url = "http://localhost:8080"

    @staticmethod
    def create_transaction(token: str, transaction: Transaction) -> Optional[Transaction]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        transaction_data = transaction.model_dump()

        response = requests.post(
            f"{TransactionRequests.backend_url}/transaction/post",
            json=transaction_data,
            headers=headers
        )

        if response.status_code == 201:  # or 200, depending on your backend
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
            # Parse transaction time
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
    def update_transaction(token: str, updated_transaction: Transaction) -> Optional[Transaction]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        transaction_data = updated_transaction.model_dump()

        response = requests.put(
            f"{TransactionRequests.backend_url}/transaction/update/{updated_transaction.id}",
            json=transaction_data,
            headers=headers
        )

        if response.status_code == 200:
            return Transaction(**response.json())
        else:
            return None

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

        url = f"{TransactionRequests.backend_url}/transaction/expenses"
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

        url = f"{TransactionRequests.backend_url}/transaction/incomes"
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            transactions_data = response.json()
            transactions = [Transaction(**transaction) for transaction in transactions_data]
            return TransactionRequests._filter_transactions_by_month_range(transactions, month_range)
        else:
            return []

    @staticmethod
    def get_recurring_expense_transactions(token: str, month_range: int = -1) -> List[Transaction]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }

        url = f"{TransactionRequests.backend_url}/transaction/recurring-expenses"
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            transactions_data = response.json()
            transactions = [Transaction(**transaction) for transaction in transactions_data]
            return TransactionRequests._filter_transactions_by_month_range(transactions, month_range)
        else:
            return []

    @staticmethod
    def get_recurring_income_transactions(token: str, month_range: int = -1) -> List[Transaction]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }

        url = f"{TransactionRequests.backend_url}/transaction/recurring-incomes"
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            transactions_data = response.json()
            transactions = [Transaction(**transaction) for transaction in transactions_data]
            return TransactionRequests._filter_transactions_by_month_range(transactions, month_range)
        else:
            return []




class BudgetRequest:
    backend_url = "http://localhost:8080"

    @staticmethod
    def create_budget(token: str, budget: Budget) -> Optional[Budget]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        budget_data = budget.model_dump()

        response = requests.post(
            f"{BudgetRequest.backend_url}/budget/post",
            json=budget_data,
            headers=headers
        )

        if response.status_code == 201:
            return Budget(**response.json())
        else:
            return None

    @staticmethod
    def read_budgets(token: str) -> List[Budget]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }

        response = requests.get(
            f"{BudgetRequest.backend_url}/budget/all",
            headers=headers
        )

        if response.status_code == 200:
            budgets_data = response.json()
            return [Budget(**budget) for budget in budgets_data]
        else:
            return []

    @staticmethod
    def update_budget(token: str, updated_budget: Budget) -> Optional[Budget]:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        budget_data = updated_budget.model_dump()

        response = requests.put(
            f"{BudgetRequest.backend_url}/budget/update/{updated_budget.id}",
            json=budget_data,
            headers=headers
        )

        if response.status_code == 200:
            return Budget(**response.json())
        else:
            return None

    @staticmethod
    def delete_budget(token: str, budget_id: int) -> bool:
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }

        response = requests.delete(
            f"{BudgetRequest.backend_url}/budget/delete/{budget_id}",
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
