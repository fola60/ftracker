package com.ftracker.server.controller;

import com.ftracker.server.dto.TransactionRequest;
import com.ftracker.server.entity.Transaction;
import com.ftracker.server.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/transaction")
public class TransactionController {

    @Autowired
    private TransactionService transactionService;

    @GetMapping("/get-all/{user_id}")
    public List<Transaction> getAllTransactions(@PathVariable Integer user_id) {
        return transactionService.getAllTransactions(user_id);
    }

    @GetMapping("/get-all-expenses/{user_id}")
    public List<Transaction> getAllExpenses(@PathVariable Integer user_id) {
        return transactionService.getAllExpense(user_id);
    }

    @GetMapping("/get-all-incomes/{user_id}")
    public List<Transaction> getAllIncomes(@PathVariable Integer user_id) {
        return transactionService.getAllIncome(user_id);
    }

    @GetMapping("/get-all-recurring-incomes/{user_id}")
    public List<Transaction> getAllRecurringIncomes(@PathVariable Integer user_id) {
        return transactionService.getAllRecurringIncome(user_id);
    }

    @GetMapping("/get-all-recurring-expenses/{user_id}")
    public List<Transaction> getAllRecurringExpenses(@PathVariable Integer user_id) {
        return transactionService.getAllRecurringExpense(user_id);
    }

    @PostMapping("/post")
    public Transaction saveTransaction(@Validated @RequestBody TransactionRequest transactionRequest) {
        return transactionService.saveTransaction(transactionRequest);
    }

    @DeleteMapping("/delete/{id}")
    public void deleteTransaction(@PathVariable Integer id) {
        transactionService.deleteTransaction(id);
    }
}
