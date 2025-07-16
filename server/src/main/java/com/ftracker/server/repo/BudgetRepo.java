package com.ftracker.server.repo;

import com.ftracker.server.entity.Budget;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BudgetRepo extends JpaRepository<Budget, Integer> {

    @Query(value = "SELECT CASE \n" +
            "    WHEN :categoryId IN (SELECT category_id FROM budget_category WHERE budget_id = :budgetId) \n" +
            "    THEN true \n" +
            "    ELSE false \n" +
            "END", nativeQuery = true)
    public boolean containsCategoryById(Integer budgetId, Integer categoryId);

    @Modifying
    @Transactional
    @Query(value = "DELETE FROM budget WHERE id = :id", nativeQuery = true)
    public int deleteBudgetById(Integer id);

    @Query(value = "SELECT * FROM budget WHERE id = :budgetId", nativeQuery = true)
    public Budget getBudgetById(Integer budgetId);

    @Query(value = "SELECT * FROM budget WHERE user_id = :userId", nativeQuery = true)
    List<Budget> getBudgetByUserId(Integer userId);
}
