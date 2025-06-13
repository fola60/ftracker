from pydantic import BaseModel, Field
from enum import Enum

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


class StatementExtraction(BaseModel):
    description: str = Field(description="Raw description of the event.")
    is_expense: bool = Field(description="Whether this text describes an expense")
    is_income: bool = Field(description="Whether this text describes an income")
    is_recurring_expense: bool = Field(description="Whether this is described as a recurring expense like a subscription or bill etc or they specify it as a recurring expense.")
    is_recurring_revenue: bool = Field(description="Whether this is described as a recurring revenue source like a salary etc or they specify it as recurring income.")
    confidence_score: float = Field(description="Confidence score for is_expense or is_income between 0 and 1")

class Expense(BaseModel):
    expense_type: ExpenseType = Field(description="Type of expense", default=ExpenseType.OTHER)
    amount: float = Field(description="Cost of expense.")
    name: str = Field(description="Summarised name of the expense e.g. groceries supermarket-name")
    description: str = Field("Details of the purchase")


class Income(BaseModel):
    income_type: IncomeType = Field(description="Type of income e.g. gift, stocks, betting,  etc", default=IncomeType.OTHER)
    amount: float = Field(description="Amount receiving..")
    name: str = Field(description="Summarised name of the expense e.g. monthly salary")
    description: str = Field("Details of the purchase")


class RecurringCharge(BaseModel):
    time_recurring: int = Field(description="The frequency of the charge in days.", default=30)
    type: ExpenseType = Field(description="The type of charge", default=ExpenseType.OTHER)
    recurring_type: RecurringChargeType = Field(description="The type of recurring charge e.g. subscription, bill", default=RecurringChargeType.OTHER)
    amount: float = Field(description="Cost of recurring charge.")
    name: str = Field(description="Summarised name of the expense e.g. Amazon prime subscription")
    description: str = Field("Details of the purchase")

class RecurringRevenue(BaseModel):
    time_recurring: int = Field(description="The frequency of the income in days.", default=30)
    type: RecurringRevenueType = Field(description="The type of charge", default=RecurringRevenueType.OTHER)
    amount: float = Field(description="Cost of charge.")
    name: str = Field(description="Summarised name of the expense e.g. Amazon prime subscription")
    description: str = Field("Details of the purchase")