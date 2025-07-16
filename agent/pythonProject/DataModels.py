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

class ResponseType(Enum):
    EXPENSE = "EXPENSE"
    INCOME = "INCOME"
    RECURRING_CHARGE = "RECURRING_CHARGE"
    RECURRING_REVENUE = "RECURRING_REVENUE"
    ERROR = "ERROR"

class TransactionType(Enum):
    EXPENSE = "EXPENSE"
    INCOME = "INCOME"
    RECURRING_EXPENSE = "RECURRING_EXPENSE"
    RECURRING_INCOME = "RECURRING_INCOME"


class StatementExtraction(BaseModel):
    description: str = Field(description="Raw description of the event.")
    is_expense: bool = Field(description="Whether this text contains an expense")
    is_income: bool = Field(description="Whether this text contains an income")
    is_recurring_expense: bool = Field(description="Whether this is described as a recurring expense like a subscription or bill etc or they specify it as a recurring expense.")
    is_recurring_revenue: bool = Field(description="Whether this is described as a recurring revenue source like a salary etc or they specify it as recurring income.")
#
# class Expense(BaseModel):
#     id: int = Field(description="Integer id of user")
#     type: ExpenseType = Field(description="The type of expense.")
#     time: str = Field(description="When the expense was purchased.")
#     amount: float = Field(description="How much was paid for the expense.")
#     name: str = Field(description="The name of the expense")
#     description: str = Field(description="A description of any details related to the expense.")
#
# class Income(BaseModel):
#     id: int = Field(description="Integer id of user")
#     type: IncomeType = Field(description="The type of income.")
#     amount: float = Field(description="How much was received for the income.")
#     time: str = Field(description="When the income was received.")
#     name: str = Field(description="The name of the income")
#     description: str = Field(description="A description of any details related to the income.")
#
# class RecurringCharge(BaseModel):
#     id: int = Field(description="Integer id of user")
#     time_recurring: int = Field(description="The frequency of the charge, in days.")
#     next_date: str = Field(description="The date of the next charge.")
#     type: ExpenseType = Field(description="The type of charge.")
#     recurring_type: RecurringChargeType = Field(description="The type of recurring charge type.")
#     amount: float = Field(description="How much was paid for the charge.")
#     name: str = Field(description="The name of the charge")
#     description: str = Field(description="A description of any details related to the expense.")
#
# class RecurringRevenue(BaseModel):
#     id: int = Field(description="Integer id of user")
#     time_recurring: int = Field(description="The frequency of the revenue, in days.")
#     next_date: str = Field(description="The date of the next revenue.")
#     amount: float = Field(description="How much is received.")
#     type: RecurringRevenueType = Field(description="The type of revenue.")
#     name: str = Field(description="A summarised name of the revenue")
#     description: str = Field(description="A description of any details related to the revenue.")
#
#
# class Expenses(BaseModel):
#     expense_type: list[ExpenseType] = Field(description="Type of expense", default=ExpenseType.OTHER)
#     cost: list[float] = Field(description="Cost of expense.")
#     name: list[str] = Field(description="Summarised name of the expense e.g. groceries supermarket-name")
#     description: list[str] = Field(description="Details of the purchase")
#
#
# class Incomes(BaseModel):
#     income_type: list[IncomeType] = Field(description="Type of income e.g. gift, stocks, betting,  etc", default=IncomeType.OTHER)
#     amount: list[float] = Field(description="Amount receiving..")
#     name: list[str] = Field(description="Summarised name of the expense e.g. monthly salary")
#     description: list[str] = Field(description="Details of the purchase")
#
#
# class RecurringCharges(BaseModel):
#     time_recurring: list[int] = Field(description="The frequency of the charge in days.", default=30)
#     type: list[ExpenseType] = Field(description="The type of charge", default=ExpenseType.OTHER)
#     recurring_type: list[RecurringChargeType] = Field(description="The type of recurring charge e.g. subscription, bill", default=RecurringChargeType.OTHER)
#     cost: list[float] = Field(description="Cost of recurring charge.")
#     name: list[str] = Field(description="Summarised name of the expense e.g. Amazon prime subscription")
#     description: list[str] = Field(description="Details of the purchases")
#
#
# class RecurringRevenues(BaseModel):
#     time_recurring: list[int] = Field(description="The frequency of the income in days.", default=30)
#     type: list[RecurringRevenueType] = Field(description="The type of charge", default=RecurringRevenueType.OTHER)
#     amount: list[float] = Field(description="Cost of charge.")
#     name: list[str] = Field(description="Summarised name of the expense e.g. Amazon prime subscription")
#     description: list[str] = Field(description="Details of the revenue")


class Response(BaseModel):
    success: bool = Field(description="Whether the operation was successful", default=False)
    error_message: Optional[str] = Field(description="Description of the error, if any", default="None")
    type: ResponseType



class Category(BaseModel):
    id: int
    headCategory: HeadCategoryType
    name: str

class Transaction(BaseModel):
    id: int
    category: Optional[Category] = Field(description="The category of transaction")
    time: str = Field(description="The time of the transaction.")
    amount: list[float] = Field(description="Amount of transaction")
    name: list[str] = Field(description="Summarised name of the transaction e.g. monthly salary")
    description: list[str] = Field(description="Details of the transaction.")
    transactionType: TransactionType
    time_recurring: Optional[int]= Field(description="Time in days the transaction re occurs if its a recurring transaction.")


class BudgetCategory(BaseModel):
    id: int
    categoryId: Category = Field(description="The category information")
    budgetAmount: float = Field(description="The amount the user can spend within a month on this category")


class Budget(BaseModel):
    id: int
    budgetCategories: list[BudgetCategory]
    name: str = Field(description="The name of the budget")