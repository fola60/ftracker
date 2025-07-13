package com.ftracker.server.service;

import com.ftracker.server.dto.ExpenseRequest;
import com.ftracker.server.entity.Expense;
import com.ftracker.server.entity.User;
import com.ftracker.server.repo.ExpenseRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ExpenseService {
    @Autowired
    private ExpenseRepo expenseRepo;
    
    @Autowired
    private UserService userService;

    public List<Expense> getAllExpenseById(Integer id) {
        return expenseRepo.getAllExpenseById(id);
    }

    public Optional<Expense> getExpenseById(Integer id) {
        return expenseRepo.findById(id);
    }

    public Expense saveExpense(ExpenseRequest expenseRequest) {
        Expense expense = new Expense();
        User user = userService.getUserById(expenseRequest.getUser_id());

        if (expense.getTime() == null) {
            expense.setTime(LocalDate.now());
        }
        expense.setAmount(expenseRequest.getAmount());
        // TODO: set category
        expense.setName(expenseRequest.getName());
        expense.setDescription(expenseRequest.getDescription());
        user.getExpenses().add(expense);
        expense.setUser(user);

        return expenseRepo.save(expense);
    }

    public boolean deleteExpense(Integer id) {
        int deleted = expenseRepo.deleteExpenseById(id);
        return deleted != 0;
    }

}
