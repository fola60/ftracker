package com.ftracker.server.entity;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "user_table")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @Column(name = "time_added", nullable = false)
    private LocalDate timeAdded;

    @Column(name="balance", nullable = false)
    private Double balance;

    @OneToMany(mappedBy = "user")
    private List<RecurringRevenue> recurringRevenues = new ArrayList<>();

    @OneToMany(mappedBy = "user")
    private List<RecurringCharge> recurringCharges = new ArrayList<>();

    @OneToMany(mappedBy = "user")
    private List<Expense> expenses = new ArrayList<>();

    @OneToMany(mappedBy = "user")
    private List<Income> Incomes = new ArrayList<>();

    public List<RecurringRevenue> getRecurringRevenues() {
        return recurringRevenues;
    }

    public void setRecurringRevenues(List<RecurringRevenue> recurringRevenues) {
        this.recurringRevenues = recurringRevenues;
    }

    public List<RecurringCharge> getRecurringCharges() {
        return recurringCharges;
    }

    public void setRecurringCharges(List<RecurringCharge> recurringCharges) {
        this.recurringCharges = recurringCharges;
    }

    public List<Expense> getExpenses() {
        return expenses;
    }

    public void setExpenses(List<Expense> expens) {
        this.expenses = expens;
    }

    public List<Income> getIncomes() {
        return Incomes;
    }

    public void setIncomes(List<Income> Incomes) {
        this.Incomes = Incomes;
    }
}
