package com.ftracker.server.repo;

import com.ftracker.server.entity.RecurringCharge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecurringChargeRepo extends JpaRepository<RecurringCharge, Integer> {
    @Query(value = "SELECT * FROM recurring_charge WHERE user_id = :id", nativeQuery = true)
    public List<RecurringCharge> getAllRecurringChargeById(Integer id);

    @Modifying
    @Query(value = "DELETE FROM recurring_charge WHERE id = :id", nativeQuery = true)
    public void deleteRecurringChargeById(Integer id);
}
