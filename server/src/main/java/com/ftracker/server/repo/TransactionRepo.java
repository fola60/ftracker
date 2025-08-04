package com.ftracker.server.repo;

import com.ftracker.server.entity.Transaction;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TransactionRepo extends JpaRepository<Transaction, Integer> {
    @Query(value = "SELECT * FROM transaction WHERE user_id = :id", nativeQuery = true)
    public List<Transaction> getAllTransactionById(Integer id);

    @Query(value = "SELECT * FROM transaction WHERE user_id = :id AND transaction_type = 0", nativeQuery = true)
    public List<Transaction> getAllExpenseById(Integer id);

    @Query(value = "SELECT * FROM transaction WHERE user_id = :id AND transaction_type = 1", nativeQuery = true)
    public List<Transaction> getAllIncomeById(Integer id);

    @Query(value = "SELECT * FROM transaction WHERE user_id = :id AND transaction_type = 2", nativeQuery = true)
    public List<Transaction> getAllRecurringExpenseById(Integer id);

    @Query(value = "SELECT * FROM transaction WHERE user_id = :id AND transaction_type = 3", nativeQuery = true)
    public List<Transaction> getAllRecurringIncomeById(Integer id);

    @Modifying
    @Transactional
    @Query(value = "DELETE FROM transaction WHERE id = :id", nativeQuery = true)
    public int deleteTransactionById(Integer id);
}
