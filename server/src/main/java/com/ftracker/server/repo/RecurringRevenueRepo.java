package com.ftracker.server.repo;

import com.ftracker.server.entity.RecurringRevenue;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecurringRevenueRepo extends JpaRepository<RecurringRevenue, Integer> {
    @Query(value = "SELECT * FROM recurring_revenue WHERE user_id = :id", nativeQuery = true)
    public List<RecurringRevenue> getAllRecurringRevenueById(Integer id);

    @Modifying
    @Query(value = "DELETE FROM recurring_revenue WHERE id = :id", nativeQuery = true)
    public void deleteRecurringRevenueById(Integer id);
}
