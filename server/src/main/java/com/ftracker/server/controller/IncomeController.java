package com.ftracker.server.controller;

import com.ftracker.server.dto.IncomeRequest;
import com.ftracker.server.entity.Income;
import com.ftracker.server.service.IncomeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/income")
public class IncomeController {
    
    @Autowired
    private IncomeService incomeService;

    @GetMapping("/get-income-by-user-id/{user_id}")
    public List<Income> getIncomes(@PathVariable Integer user_id) {
        return incomeService.getAllIncomeById(user_id);
    }

    @PostMapping("/post-income")
    public void postIncome(@Validated @RequestBody IncomeRequest incomeRequest) {
        incomeService.saveIncome(incomeRequest);
    }

    @DeleteMapping("/delete-income/{id}")
    public void deleteIncome(@PathVariable Integer id) {
        incomeService.deleteIncome(id);
    }
}
