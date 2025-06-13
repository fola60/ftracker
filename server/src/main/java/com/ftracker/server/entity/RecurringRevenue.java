package com.ftracker.server.entity;

import com.ftracker.server.enums.RecurringRevenueType;
import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "recurring_revenue")
public class RecurringRevenue {
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

    // Cost of the charge
    @Column(name = "amount", nullable = false)
    private Double amount;

    @Column(name = "type", nullable = false)
    @Enumerated(EnumType.STRING)
    private RecurringRevenueType type;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description")
    private String description;

    @ManyToOne
    @JoinColumn(name = "user_id")
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

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }


}
