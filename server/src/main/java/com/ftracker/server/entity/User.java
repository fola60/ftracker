package com.ftracker.server.entity;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
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

    @Column(name = "time_added")
    private LocalDate timeAdded;

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(name="password")
    private String password;

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(name = "verification_token")
    private String verificationToken;

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(name = "token_expiry")
    private LocalDateTime tokenExpiry;

    @Column(name = "is_verified")
    private boolean isVerified;

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(name = "reset_token_expiry")
    private LocalDateTime resetTokenExpiry;

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(name = "reset_token")
    private String resetToken;

    @OneToMany(mappedBy = "user")
    private List<RecurringRevenue> recurringRevenues = new ArrayList<>();

    @OneToMany(mappedBy = "user")
    private List<RecurringCharge> recurringCharges = new ArrayList<>();

    @OneToMany(mappedBy = "user")
    private List<Expense> expenses = new ArrayList<>();

    @OneToMany(mappedBy = "user")
    private List<Income> incomes = new ArrayList<>();

    @OneToMany(mappedBy = "user")
    private List<Budget> budgets = new ArrayList<>();

    @OneToMany(mappedBy = "user")
    private List<Category> categories = new ArrayList<>();

    public LocalDateTime getResetTokenExpiry() {
        return resetTokenExpiry;
    }

    public void setResetTokenExpiry(LocalDateTime resetTokenExpiry) {
        this.resetTokenExpiry = resetTokenExpiry;
    }

    public String getVerificationToken() {
        return verificationToken;
    }

    public void setVerificationToken(String verificationToken) {
        this.verificationToken = verificationToken;
    }

    public boolean isVerified() {
        return isVerified;
    }

    public void setVerified(boolean isVerified) {
        this.isVerified = isVerified;
    }

    public String getResetToken() {
        return resetToken;
    }

    public void setResetToken(String resetToken) {
        this.resetToken = resetToken;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public LocalDate getTimeAdded() {
        return timeAdded;
    }

    public void setTimeAdded(LocalDate timeAdded) {
        this.timeAdded = timeAdded;
    }


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
        return incomes;
    }

    public void setIncomes(List<Income> Incomes) {
        this.incomes = Incomes;
    }

    public LocalDateTime getTokenExpiry() {
        return tokenExpiry;
    }

    public void setTokenExpiry(LocalDateTime tokenExpiry) {
        this.tokenExpiry = tokenExpiry;
    }

    public List<Budget> getBudgets() {
        return budgets;
    }

    public void setBudgets(List<Budget> budgets) {
        this.budgets = budgets;
    }

    public List<Category> getCategories() {
        return categories;
    }

    public void setCategories(List<Category> categories) {
        this.categories = categories;
    }
}
