package com.ftracker.server.service;

import com.ftracker.server.dto.TransactionRequest;
import com.ftracker.server.entity.Category;
import com.ftracker.server.entity.Transaction;
import com.ftracker.server.entity.User;
import com.ftracker.server.enums.TransactionType;
import com.ftracker.server.repo.TransactionRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class TransactionService {
    @Autowired
    private TransactionRepo transactionRepo;

    @Autowired
    private UserService userService;

    @Autowired
    private CategoryService categoryService;

    public List<Transaction> getAllTransactions(Integer id) {
        return transactionRepo.getAllTransactionById(id);
    }

    public List<Transaction> getAllExpense(Integer id) {
        return transactionRepo.getAllExpenseById(id);
    }

    public List<Transaction> getAllIncome(Integer id) {
        return transactionRepo.getAllIncomeById(id);
    }

    public List<Transaction> getAllRecurringExpense(Integer id) {
        return transactionRepo.getAllRecurringExpenseById(id);
    }

    public List<Transaction> getAllRecurringIncome(Integer id) {
        return transactionRepo.getAllRecurringIncomeById(id);
    }

    public boolean deleteTransaction(Integer id) {
        int deleted = transactionRepo.deleteTransactionById(id);
        return deleted != 0;
    }

    public Transaction saveTransaction(TransactionRequest transactionRequest) {
        Transaction transaction = new Transaction();
        User user = userService.getUserById(transactionRequest.getUser_id());
        Category category = categoryService.getCategoryById(transactionRequest.getCategory_id());

        if (transactionRequest.getId() != null) {
            transaction.setId(transactionRequest.getId());
        }

        if (transactionRequest.getTime() == null) {
            transaction.setTime(LocalDate.now());
        } else {
            transaction.setTime(transactionRequest.getTime());
        }

        transaction.setName(transactionRequest.getName());
        transaction.setAmount(transactionRequest.getAmount());
        transaction.setDescription(transactionRequest.getDescription());
        transaction.setCategory(category);
        transaction.setTransactionType(transactionRequest.getTransaction_type());
        transaction.setUser(user);

        if (transactionRequest.getTransaction_type() == TransactionType.RECURRING_INCOME || transactionRequest.getTransaction_type() == TransactionType.RECURRING_EXPENSE) {
            transaction.setTime_recurring(transactionRequest.getTime_recurring());
        }

        transaction = transactionRepo.save(transaction);
        if (user != null)
            user.getTransactions().add(transaction);
        return transaction;
    }
}
