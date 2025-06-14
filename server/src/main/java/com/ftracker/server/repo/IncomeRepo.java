package com.ftracker.server.repo;

import com.ftracker.server.entity.Income;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IncomeRepo extends JpaRepository<Income, Integer> {

    @Query(value = "SELECT * FROM income WHERE user_id = :id", nativeQuery = true)
    public List<Income> getAllIncomeById(Integer id);

    @Modifying
    @Query(value = "DELETE FROM income WHERE id = :id", nativeQuery = true)
    public void deleteIncomeById(Integer id);
}
