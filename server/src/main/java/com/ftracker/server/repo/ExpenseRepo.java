package com.ftracker.server.repo;

import com.ftracker.server.entity.Expense;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExpenseRepo extends JpaRepository<Expense, Integer> {

    @Query(value = "SELECT * FROM expense WHERE user_id = :id", nativeQuery = true)
    public List<Expense> getAllExpenseById(Integer id);

    @Modifying
    @Transactional
    @Query(value = "DELETE FROM expense WHERE id = :id", nativeQuery = true)
    public int deleteExpenseById(Integer id);

}
