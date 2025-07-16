package com.ftracker.server.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;


@Entity
@Table(name = "budget_category")
public class BudgetCategory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "budget_id")
    @JsonIgnore
    private Budget budgetId;

    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category categoryId;

    @Column(name = "amount")
    private Float budgetAmount;



    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Budget getBudgetId() {
        return budgetId;
    }

    public void setBudgetId(Budget categoryId) {
        this.budgetId = categoryId;
    }


    public Float getBudgetAmount() {
        return budgetAmount;
    }

    public void setBudgetAmount(Float amount) {
        this.budgetAmount = amount;
    }


    public Category getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Category categoryId) {
        this.categoryId = categoryId;
    }


}
