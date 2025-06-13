package com.ftracker.server.service;

import com.ftracker.server.dto.ExpenseRequest;
import com.ftracker.server.entity.Expense;
import com.ftracker.server.entity.User;
import com.ftracker.server.repo.ExpenseRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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

    public void saveExpense(ExpenseRequest expenseRequest) {
        Expense expense = new Expense();
        User user = userService.getUserById(expenseRequest.getUser_id());
        
        expense.setTime(LocalDateTime.now());
        expense.setAmount(expenseRequest.getAmount());
        expense.setType(expenseRequest.getType());
        expense.setName(expenseRequest.getName());
        expense.setDescription(expense.getDescription());
        user.getExpenses().add(expense);
        expense.setUser(user);

        expenseRepo.save(expense);
    }

    public void deleteExpense(Integer id) {
        expenseRepo.deleteExpenseById(id);
    }

}
