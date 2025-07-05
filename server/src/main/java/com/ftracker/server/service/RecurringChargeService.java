package com.ftracker.server.service;

import com.ftracker.server.dto.RecurringChargeRequest;
import com.ftracker.server.entity.RecurringCharge;
import com.ftracker.server.entity.User;
import com.ftracker.server.repo.RecurringChargeRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class RecurringChargeService {

    @Autowired
    private RecurringChargeRepo recurringChargeRepo;

    @Autowired
    private UserService userService;

    public List<RecurringCharge> getAllRecurringChargeById(Integer id) {
        return recurringChargeRepo.getAllRecurringChargeById(id);
    }

    public Optional<RecurringCharge> getRecurringChargeById(Integer id) {
        return recurringChargeRepo.findById(id);
    }

    public void saveRecurringCharge(RecurringChargeRequest recurringChargeRequest) {
        LocalDate next = LocalDate.now().plusDays(recurringChargeRequest.getTime_recurring());;
        User user = userService.getUserById(recurringChargeRequest.getUser_id());
        RecurringCharge recurringCharge = new RecurringCharge();


        recurringCharge.setNext_date(next);
        recurringCharge.setTime_recurring(recurringChargeRequest.getTime_recurring());
        recurringCharge.setAmount(recurringChargeRequest.getAmount());
        recurringCharge.setDescription(recurringChargeRequest.getDescription());
        recurringCharge.setType(recurringChargeRequest.getType());
        recurringCharge.setRecurring_type(recurringChargeRequest.getRecurring_type());
        recurringCharge.setName(recurringChargeRequest.getName());
        user.getRecurringCharges().add(recurringCharge);
        recurringCharge.setUser(user);

        recurringChargeRepo.save(recurringCharge);
    }

    public boolean deleteRecurringCharge(Integer id) {
        int deleted = recurringChargeRepo.deleteRecurringChargeById(id);
        return deleted != 0;
    }
}
