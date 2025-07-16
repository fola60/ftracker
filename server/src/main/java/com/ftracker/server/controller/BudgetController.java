package com.ftracker.server.controller;

import com.ftracker.server.dto.BudgetCategoryRequest;
import com.ftracker.server.dto.BudgetRequest;
import com.ftracker.server.entity.Budget;
import com.ftracker.server.service.BudgetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/budget")
public class BudgetController {
    @Autowired
    private BudgetService budgetService;

    @GetMapping("/get-budget-by-id/{id}")
    public Budget getBudgetById(@PathVariable Integer id) {
        return budgetService.getBudgetById(id);
    }

    @GetMapping("/get-budget-by-user-id/{id}")
    public List<Budget> getBudgetsByUserId(@PathVariable Integer id) {
        return budgetService.getBudgetByUserId(id);
    }

    @PostMapping("/save-budget")
    public Budget saveBudget(@Validated @RequestBody BudgetRequest budgetRequest) {
        return budgetService.saveBudget(budgetRequest);
    }

    @PostMapping("/save-budget-category")
    public boolean saveBudgetCategory(@Validated @RequestBody BudgetCategoryRequest budgetCategoryRequest) {
        return budgetService.saveBudgetCategory(budgetCategoryRequest);
    }

    @DeleteMapping("/delete-budget/{id}")
    public boolean deleteBudget(@PathVariable Integer id) {
        return budgetService.deleteBudget(id);
    }

    @DeleteMapping("/delete-budget-category/{id}")
    public boolean deleteBudgetCategory(@PathVariable Integer id) {
        return budgetService.deleteBudgetCategory(id);
    }
}
