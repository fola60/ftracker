package com.ftracker.server.controller;

import com.ftracker.server.dto.ExpenseRequest;
import com.ftracker.server.entity.Expense;
import com.ftracker.server.service.ExpenseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/expense")
public class ExpenseController {

    @Autowired
    private ExpenseService expenseService;

    @GetMapping("/get-expense-by-user-id/{user_id}")
    public List<Expense> getExpenses(@PathVariable Integer user_id) {
        return expenseService.getAllExpenseById(user_id);
    }

    @PostMapping("/post-expense")
    public void postExpense(@Validated @RequestBody ExpenseRequest expenseRequest) {
        expenseService.saveExpense(expenseRequest);
    }

    @DeleteMapping("/delete-expense/{id}")
    public void deleteExpense(@PathVariable Integer id) {
        expenseService.deleteExpense(id);
    }

}
