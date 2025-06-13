package com.ftracker.server.dto;

import com.ftracker.server.enums.RecurringRevenueType;

import java.time.LocalDate;

public class RecurringRevenueRequest {
    private Integer time_recurring;
    private LocalDate next_date;
    private Double amount;
    private RecurringRevenueType type;
    private String name;
    private String description;
    private Integer user_id;

    public Double getAmount() {
        return amount;
    }

    public void setAmount(Double amount) {
        this.amount = amount;
    }

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

    public RecurringRevenueType getType() {
        return type;
    }

    public void setType(RecurringRevenueType type) {
        this.type = type;
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