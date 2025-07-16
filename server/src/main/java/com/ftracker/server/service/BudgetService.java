package com.ftracker.server.service;

import com.ftracker.server.dto.BudgetCategoryRequest;
import com.ftracker.server.dto.BudgetRequest;
import com.ftracker.server.entity.Budget;
import com.ftracker.server.entity.BudgetCategory;
import com.ftracker.server.entity.Category;
import com.ftracker.server.entity.User;
import com.ftracker.server.repo.BudgetCategoryRepo;
import com.ftracker.server.repo.BudgetRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class BudgetService {

    @Autowired
    private BudgetCategoryRepo budgetCategoryRepo;

    @Autowired
    private BudgetRepo budgetRepo;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private UserService userService;

    public Budget saveBudget(BudgetRequest budgetRequest) {
        Budget budget = new Budget();
        User user = userService.getUserById(budgetRequest.getUser_id());

        if (budgetRequest.getUser_id() != null) {
            budget.setId(budgetRequest.getId());
        }

        budget.setName(budgetRequest.getName());
        budget.setUser(user);

        budgetRepo.save(budget);
        user.getBudgets().add(budget);

        return budget;
    }

    public boolean deleteBudget(Integer budgetId) {
        int deleted = budgetRepo.deleteBudgetById(budgetId);
        return deleted == 1;
    }

    public boolean saveBudgetCategory(BudgetCategoryRequest budgetCategoryRequest) {
        BudgetCategory budgetCategory = new BudgetCategory();
        Budget budget = getBudgetById(budgetCategoryRequest.getBudget_id());
        Category category = categoryService.getCategoryById(budgetCategoryRequest.getCategory_id());

        if (budgetRepo.containsCategoryById(budgetCategoryRequest.getBudget_id(), budgetCategoryRequest.getCategory_id())) {
            return false;
        }

        if (budgetCategoryRequest.getBudget_id() != null) {
            budgetCategory.setId(budgetCategoryRequest.getId());
        }

        budgetCategory.setBudgetAmount(budgetCategory.getBudgetAmount());
        budgetCategory.setBudgetId(budget);
        budgetCategory.setCategoryId(category);

        budgetCategoryRepo.save(budgetCategory);
        budget.getBudgetCategories().add(budgetCategory);

        return true;
    }

    public boolean deleteBudgetCategory(Integer budgetCategoryId) {
        int deleted = budgetCategoryRepo.deleteBudgetCategoryById(budgetCategoryId);
        return deleted == 1;
    }

    public Budget getBudgetById(Integer budgetId) {
        return budgetRepo.getBudgetById(budgetId);
    }

    public List<Budget> getBudgetByUserId(Integer userId) {
        return budgetRepo.getBudgetByUserId(userId);
    }


    public void save(Budget budget) {
        budgetRepo.save(budget);
    }

    public void saveBudgetCategoryMod(BudgetCategory budgetCategory) {
        budgetCategoryRepo.save(budgetCategory);
    }
}
