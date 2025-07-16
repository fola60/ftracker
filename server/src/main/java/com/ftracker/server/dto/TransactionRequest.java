package com.ftracker.server.dto;
import com.ftracker.server.enums.TransactionType;

import java.time.LocalDate;

public class TransactionRequest {
    private Integer id;
    private Double amount;
    private String name;
    private String description;
    private LocalDate time;
    private Integer time_recurring;
    private TransactionType transaction_type;
    private Integer user_id;
    private Integer category_id;

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

    public Integer getTime_recurring() {
        return time_recurring;
    }

    public void setTime_recurring(Integer time_recurring) {
        this.time_recurring = time_recurring;
    }

    public LocalDate getTime() {
        return time;
    }

    public void setTime(LocalDate time) {
        this.time = time;
    }

    public TransactionType getTransaction_type() {
        return transaction_type;
    }

    public void setTransaction_type(TransactionType transaction_type) {
        this.transaction_type = transaction_type;
    }

    public Integer getUser_id() {
        return user_id;
    }

    public void setUser_id(Integer user_id) {
        this.user_id = user_id;
    }

    public Integer getCategory_id() {
        return category_id;
    }

    public void setCategory_id(Integer category_id) {
        this.category_id = category_id;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }
}
