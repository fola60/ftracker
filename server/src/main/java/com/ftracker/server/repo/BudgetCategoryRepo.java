package com.ftracker.server.repo;

import com.ftracker.server.entity.BudgetCategory;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BudgetCategoryRepo extends JpaRepository<BudgetCategory, Integer> {

    @Modifying
    @Transactional
    @Query(value = "DELETE FROM budget_category WHERE id = :id", nativeQuery = true)
    public int deleteBudgetCategoryById(Integer id);


}
