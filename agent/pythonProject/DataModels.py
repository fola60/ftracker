from pydantic import BaseModel, Field
from enum import Enum
from typing import Optional

class ExpenseType(Enum):
    BILLS = "BILLS"
    CAR = "CAR"
    CLOTHES = "CLOTHES"
    COMMUNICATIONS = "COMMUNICATIONS"
    EATING_OUT = "EATING_OUT"
    ENTERTAINMENT = "ENTERTAINMENT"
    GROCERIES = "GROCERIES"
    GIFTS = "GIFTS"
    HEALTH = "HEALTH"
    HOUSE = "HOUSE"
    PETS = "PETS"
    SPORTS = "SPORTS"
    TRANSPORTATION = "TRANSPORTATION"
    OTHER = "OTHER"

class RecurringChargeType(Enum):
    SUBSCRIPTIONS = "SUBSCRIPTIONS"
    BILLS = "BILLS"
    OTHER = "OTHER"

class IncomeType(Enum):
    DEPOSITS = "DEPOSITS"
    SALARY = "SALARY"
    SAVINGS = "SAVINGS"
    OTHER = "OTHER"

class RecurringRevenueType(Enum):
    SALARY = "SALARY"
    SAVINGS = "SAVINGS"
    FINANCIAL_AID = "FINANCIAL_AID"
    OTHER = "OTHER"

class ResponseType(Enum):
    EXPENSE = "EXPENSE"
    INCOME = "INCOME"
    RECURRING_CHARGE = "RECURRING_CHARGE"
    RECURRING_REVENUE = "RECURRING_REVENUE"
    ERROR = "ERROR"


class StatementExtraction(BaseModel):
    description: str = Field(description="Raw description of the event.")
    is_expense: bool = Field(description="Whether this text contains an expense")
    is_income: bool = Field(description="Whether this text contains an income")
    is_recurring_expense: bool = Field(description="Whether this is described as a recurring expense like a subscription or bill etc or they specify it as a recurring expense.")
    is_recurring_revenue: bool = Field(description="Whether this is described as a recurring revenue source like a salary etc or they specify it as recurring income.")


class Expense(BaseModel):
    expense_type: list[ExpenseType] = Field(description="Type of expense", default=ExpenseType.OTHER)
    cost: list[float] = Field(description="Cost of expense.")
    name: list[str] = Field(description="Summarised name of the expense e.g. groceries supermarket-name")
    description: list[str] = Field(description="Details of the purchase")


class Income(BaseModel):
    income_type: list[IncomeType] = Field(description="Type of income e.g. gift, stocks, betting,  etc", default=IncomeType.OTHER)
    amount: list[float] = Field(description="Amount receiving..")
    name: list[str] = Field(description="Summarised name of the expense e.g. monthly salary")
    description: list[str] = Field(description="Details of the purchase")


class RecurringCharge(BaseModel):
    time_recurring: list[int] = Field(description="The frequency of the charge in days.", default=30)
    type: list[ExpenseType] = Field(description="The type of charge", default=ExpenseType.OTHER)
    recurring_type: list[RecurringChargeType] = Field(description="The type of recurring charge e.g. subscription, bill", default=RecurringChargeType.OTHER)
    cost: list[float] = Field(description="Cost of recurring charge.")
    name: list[str] = Field(description="Summarised name of the expense e.g. Amazon prime subscription")
    description: list[str] = Field(description="Details of the purchase")


class RecurringRevenue(BaseModel):
    time_recurring: list[int] = Field(description="The frequency of the income in days.", default=30)
    type: list[RecurringRevenueType] = Field(description="The type of charge", default=RecurringRevenueType.OTHER)
    amount: list[float] = Field(description="Cost of charge.")
    name: list[str] = Field(description="Summarised name of the expense e.g. Amazon prime subscription")
    description: list[str] = Field(description="Details of the purchase")


class Response(BaseModel):
    success: bool = Field(description="Whether the operation was successful", default=False)
    error_message: Optional[str] = Field(description="Description of the error, if any", default="None")
    type: ResponseType


class ExpenseResponse(Response):
    expense: Expense


class IncomeResponse(Response):
    income: Income


class RecurringChargeResponse(Response):
    recurringCharge: RecurringCharge


class RecurringRevenueResponse(Response):
    recurringRevenue: RecurringRevenue
