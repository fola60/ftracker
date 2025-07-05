package com.ftracker.server.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.ftracker.server.enums.ExpenseType;
import com.ftracker.server.enums.RecurringChargeType;
import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.temporal.TemporalAmount;

@Entity
@Table(name = "recurring_charge")
public class RecurringCharge {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    // Time in days charge occurs
    @Column(name = "time_recurring")
    private Integer time_recurring;

    // Next date of the charge
    @Column(name = "next_date")
    private LocalDate next_date;

    @Column(name = "type", nullable = false)
    @Enumerated(EnumType.STRING)
    private ExpenseType type;

    // This can be Subscription, bills, transport etc
    @Column(name = "recurring_type", nullable = false)
    @Enumerated(EnumType.STRING)
    private RecurringChargeType recurring_type;

    // Cost of the charge
    @Column(name = "amount", nullable = false)
    private Double amount;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description")
    private String description;

    @ManyToOne
    @JoinColumn(name = "user_id")
    @JsonIgnore
    private User user;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
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

    public Double getAmount() {
        return amount;
    }

    public void setAmount(Double amount) {
        this.amount = amount;
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

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
