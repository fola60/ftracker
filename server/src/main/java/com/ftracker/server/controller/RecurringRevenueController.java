package com.ftracker.server.controller;

import com.ftracker.server.dto.RecurringRevenueRequest;
import com.ftracker.server.entity.RecurringRevenue;
import com.ftracker.server.service.RecurringRevenueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/recurring-revenues")
public class RecurringRevenueController {
    @Autowired
    private RecurringRevenueService recurringRevenueService;

    @GetMapping("/get-recurring-revenue/{user_id}")
    public List<RecurringRevenue> getAllRecurringRevenueById(@PathVariable Integer user_id) {
        return recurringRevenueService.getAllRecurringRevenueById(user_id);
    }

    @PostMapping("/post-recurring-revenue")
    public void postRecurringRevenue(@Validated @RequestBody RecurringRevenueRequest recurringRevenueRequest) {
        recurringRevenueService.saveRecurringRevenue(recurringRevenueRequest);
    }

    @DeleteMapping("/delete-recurring-revenue/{id}")
    public void deleteRecurringRevenue(@PathVariable Integer id) {
        recurringRevenueService.deleteRecurringRevenue(id);
    }
}
