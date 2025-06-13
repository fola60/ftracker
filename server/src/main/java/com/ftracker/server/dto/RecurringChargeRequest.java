package com.ftracker.server.dto;

import com.ftracker.server.enums.ExpenseType;
import com.ftracker.server.enums.RecurringChargeType;

import java.time.LocalDate;

public class RecurringChargeRequest {

    private Integer time_recurring;
    private LocalDate next_date;
    private ExpenseType type;
    private RecurringChargeType recurring_type;
    private Double amount;
    private String name;
    private String description;
    private Integer user_id;


    public Integer getTime_recurring() {
        return time_recurring;
    }

    public void setTime_recurring(Integer time_recurring) {
        this.time_recurring = time_recurring;
    }

    public LocalDate getNext_date() {
        return next_date;
    }

    public void setNext_date(LocalDate next_date) {
        this.next_date = next_date;
    }

    public ExpenseType getType() {
        return type;
    }

    public void setType(ExpenseType type) {
        this.type = type;
    }

    public RecurringChargeType getRecurring_type() {
        return recurring_type;
    }

    public void setRecurring_type(RecurringChargeType recurring_type) {
        this.recurring_type = recurring_type;
    }

    public Double getAmount() {
        return amount;
    }

    public void setAmount(Double amount) {
        this.amount = amount;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getUser_id() {
        return user_id;
    }

    public void setUser_id(Integer user_id) {
        this.user_id = user_id;
    }
}