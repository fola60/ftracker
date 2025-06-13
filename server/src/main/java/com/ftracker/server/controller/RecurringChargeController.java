package com.ftracker.server.controller;

import com.ftracker.server.dto.RecurringChargeRequest;
import com.ftracker.server.entity.RecurringCharge;
import com.ftracker.server.service.RecurringChargeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/recurring-charges")
public class RecurringChargeController {

    @Autowired
    private RecurringChargeService recurringChargeService;

    @GetMapping("/get-recurring-charge/{user_id}")
    public List<RecurringCharge> getAllRecurringChargeById(@PathVariable Integer user_id) {
        return recurringChargeService.getAllRecurringChargeById(user_id);
    }

    @PostMapping("/post-recurring-charge")
    public void postRecurringCharge(@Validated @RequestBody RecurringChargeRequest recurringChargeRequest) {
        recurringChargeService.saveRecurringCharge(recurringChargeRequest);
    }

    @DeleteMapping("/delete-recurring-charge/{id}")
    public void deleteRecurringCharge(@PathVariable Integer id) {
        recurringChargeService.deleteRecurringCharge(id);
    }
}
