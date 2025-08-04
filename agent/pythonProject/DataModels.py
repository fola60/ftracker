from pydantic import BaseModel, Field
from enum import Enum
from typing import Optional

class HeadCategoryType(Enum):
    ENTERTAINMENT = "ENTERTAINMENT"
    FOOD_AND_DRINKS = "FOOD_AND_DRINKS"
    HOUSING = "HOUSING"
    INCOME = "INCOME"
    LIFESTYLE = "LIFESTYLE"
    MISCELLANEOUS = "MISCELLANEOUS"
    SAVINGS = "SAVINGS"
    TRANSPORTATION = "TRANSPORTATION"


class TransactionType(Enum):
    EXPENSE = "EXPENSE"
    INCOME = "INCOME"
    RECURRING_EXPENSE = "RECURRING_EXPENSE"
    RECURRING_INCOME = "RECURRING_INCOME"

class StatementType(Enum):
    BUDGET = "BUDGET"
    TRANSACTION = "TRANSACTION"
    INFO = "INFO"
    ERROR = "ERROR"

class CrudActionType(Enum):
    CREATE = "CREATE"
    READ = "READ"
    UPDATE = "UPDATE"
    DELETE = "DELETE"
    NONE = "NONE"

class StatementItem(BaseModel):
    description: str = Field(description="Raw description of the individual action requested.")
    type: StatementType = Field(description="The main type of the action requested (e.g., TRANSACTION, BUDGET, INFO).")
    confidence: Optional[float] = Field(default=None, description="Optional confidence score for this classification.")

class StatementExtraction(BaseModel):
    is_finance_statement: bool = Field(
        description="Indicates whether the input text relates to a financial operation such as creating, updating, retrieving, or deleting a transaction or budget, or requesting information about them."
    )
    statements: list[StatementItem] = Field(
        description="List of parsed statements/actions from the user input."
    )

class Category(BaseModel):
    id: int = Field(description="The id of this category")
    headCategory: HeadCategoryType = Field(description="The head category this category belongs to.")
    name: str = Field(description="The name of this category")

class CategoryRequestModel(BaseModel):
    head_category: HeadCategoryType = Field(description="The head category this category belongs to.")
    name: str = Field(description="The name of this category")
    user_id: int = Field(description="The user id this category belongs to.")

class Transaction(BaseModel):
    id: int
    category: Optional[Category] = Field(description="The category of transaction")
    time: str = Field(description="The time of the transaction.")
    amount: float = Field(description="Amount of transaction")
    name: str = Field(description="Summarised name of the transaction e.g. monthly salary")
    description: str = Field(description="Details of the transaction.")
    transactionType: TransactionType
    time_recurring: Optional[int]= Field(description="Time in days the transaction re occurs if its a recurring transaction.")

class TransactionRequestModel(BaseModel):
    amount: float = Field(description="Amount of transaction")
    name: str = Field(description="Summarised name of the transaction e.g. monthly salary")
    description: str = Field(description="Details of the transaction.")
    time: str = Field(description="The time of the transaction.")
    time_recurring: Optional[int] = Field(description="Time in days the transaction re occurs if its a recurring transaction.")
    transaction_type: TransactionType
    user_id: int = Field(description="The id of the user")
    category_id: int = Field(description="The id of the category of transaction")


class BudgetCategory(BaseModel):
    id: int
    categoryId: Category = Field(description="The category information")
    budgetAmount: float = Field(description="The amount the user can spend within a month on this category")

class BudgetCategoryRequestModel(BaseModel):
    budget_id: int = Field(description="The id of the budget this is being added to.")
    amount: float = Field(description="The monthly cap for this category.")
    category_id: int = Field(description="The id of the category of this budget")

class Budget(BaseModel):
    id: int
    budgetCategories: list[BudgetCategory]
    name: str = Field(description="The name of the budget")

class BudgetRequestModel(BaseModel):
    name:str = Field(description="The name of the budget")
    user_id: int = Field(description="The id of the user this belongs to.")

class Response(BaseModel):
    success: bool = Field(description="Whether the operation was successful", default=False)
    error_message: Optional[str] = Field(description="Description of the error, if any", default="None")
    type: StatementType

class TransactionResponse(Response):
    action: str = Field(description="A user friendly description, of the actions completed for the user.")
    transaction_id: Optional[int] = Field(description="The id of the transaction that was created, updated or deleted")
    action_type: CrudActionType = Field(description="What type of action was taken. Whether a transaction was created, read, updated, deleted or no action.")

class BudgetResponse(Response):
    action: str = Field(description="A user friendly description, of the actions completed for the user.")
    budgets: list[Budget] = Field(description="The budget's that was created, updated or deleted")
    action_type: CrudActionType = Field(description="What type of action was taken. Whether a budget was created, read, updated, deleted or no action.")

class InfoResponse(Response):
    action: str = Field(description="A user friendly response to their request.")
    transaction: Optional[list[Transaction]] = Field(description="The possible transaction object the user requested")
    budgets: Optional[list[Budget]] = Field(description="The possible budget object the user requested")

class FinanceRequest(BaseModel):
    request: str
    token: str
    chat_history: list[str]