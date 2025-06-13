package com.ftracker.server.service;

import com.ftracker.server.dto.RecurringRevenueRequest;
import com.ftracker.server.entity.RecurringRevenue;
import com.ftracker.server.entity.User;
import com.ftracker.server.repo.RecurringRevenueRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class RecurringRevenueService {

    @Autowired
    private RecurringRevenueRepo recurringRevenueRepo;

    @Autowired
    private UserService userService;



    public List<RecurringRevenue> getAllRecurringRevenueById(Integer id) {
        return recurringRevenueRepo.getAllRecurringRevenueById(id);
    }

    public Optional<RecurringRevenue> getRecurringRevenueById(Integer id) {
        return recurringRevenueRepo.findById(id);
    }

    public void saveRecurringRevenue(RecurringRevenueRequest recurringRevenueRequest) {
        RecurringRevenue recurringRevenue = new RecurringRevenue();
        LocalDate next = LocalDate.now().plusDays(recurringRevenueRequest.getTime_recurring());
        User user = userService.getUserById(recurringRevenueRequest.getUser_id());

        recurringRevenue.setNext_date(next);
        recurringRevenue.setAmount(recurringRevenueRequest.getAmount());
        recurringRevenue.setDescription(recurringRevenueRequest.getDescription());
        recurringRevenue.setTime_recurring(recurringRevenueRequest.getTime_recurring());
        recurringRevenue.setName(recurringRevenueRequest.getName());
        recurringRevenue.setType(recurringRevenueRequest.getType());
        user.getRecurringRevenues().add(recurringRevenue);
        recurringRevenue.setUser(user);

        recurringRevenueRepo.save(recurringRevenue);
    }

    public void deleteRecurringRevenue(Integer id) {
        recurringRevenueRepo.deleteRecurringRevenueById(id);
    }
}
