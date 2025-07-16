package com.ftracker.server.service;

import com.ftracker.server.entity.Budget;
import com.ftracker.server.entity.BudgetCategory;
import com.ftracker.server.entity.Category;
import com.ftracker.server.entity.User;
import com.ftracker.server.enums.HeadCategoryType;
import com.ftracker.server.repo.UserRepo;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
public class UserService {

    @Autowired
    private UserRepo userRepo;

    @Autowired
    @Lazy
    private AuthenticationManager authManager;

    @Autowired
    private JWTService jwtService;

    @Autowired
    @Lazy
    private CategoryService categoryService;

    @Autowired
    @Lazy
    private BudgetService budgetService;


    private BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(12);

    public User getUserById(Integer id) {
        return userRepo.getUserById(id);
    }

    @Transactional
    public boolean saveUser(User user) {
        if (userRepo.getUserByEmail(user.getEmail()) == null) {
            user.setPassword(encoder.encode(user.getPassword()));
            user.setTimeAdded(LocalDate.now());

            user = userRepo.save(user);

            List<Category> defaultCategories = getDefaultCategories();

            for (Category category : defaultCategories) {
                category.setUser(user);
                categoryService.save(category);
            }

            defaultCategories = categoryService.getCategoryByUserId(user.getId());

            Budget budget = new Budget();
            budget.setUser(user);
            budget.setName("My Household");


            for (Category category : defaultCategories) {
                BudgetCategory budgetCategory = new BudgetCategory();
                budgetCategory.setBudgetAmount(0.00F);
                budgetCategory.setCategoryId(category);
                budgetCategory.setBudgetId(budget);
                budgetService.saveBudgetCategoryMod(budgetCategory);
                budget.getBudgetCategories().add(budgetCategory);
            }

            budgetService.save(budget);

            user.getBudgets().add(budget);
            userRepo.save(user);

            return true;
        } else {
            return false;
        }
    }

    public List<Category> getDefaultCategories() {
        List<Category> defaultCategories = new ArrayList<>();

        defaultCategories.add(new Category("Salary", HeadCategoryType.INCOME));
        defaultCategories.add(new Category("Savings", HeadCategoryType.SAVINGS));
        defaultCategories.add(new Category("Rent", HeadCategoryType.HOUSING));
        defaultCategories.add(new Category("Electricity", HeadCategoryType.HOUSING));
        defaultCategories.add(new Category("Internet", HeadCategoryType.HOUSING));
        defaultCategories.add(new Category("Telephone", HeadCategoryType.HOUSING));
        defaultCategories.add(new Category("Tv", HeadCategoryType.ENTERTAINMENT));
        defaultCategories.add(new Category("Restaurant", HeadCategoryType.FOOD_AND_DRINKS));
        defaultCategories.add(new Category("Groceries", HeadCategoryType.FOOD_AND_DRINKS));
        defaultCategories.add(new Category("Cloths", HeadCategoryType.LIFESTYLE));
        defaultCategories.add(new Category("Gym", HeadCategoryType.LIFESTYLE));
        defaultCategories.add(new Category("Public Transport", HeadCategoryType.TRANSPORTATION));
        defaultCategories.add(new Category("Vehicle", HeadCategoryType.TRANSPORTATION));

        return defaultCategories;
    }

    @Transactional
    public boolean resetPassword(User user, String newPassword) {
        try {
            user.setPassword(encoder.encode(newPassword));
            user.setResetToken(null);
            user.setResetTokenExpiry(null);
            userRepo.save(user);
            return true;
        } catch (Exception e) {
            return false;
        }
    }


    public User getUserByVerificationToken(String token) {
        return userRepo.findByVerificationToken(token);
    }

    public User getUserByPasswordResetToken(String token) {
        return userRepo.findByResetToken(token);
    }

    public User getUserByEmail(String email) {
        return userRepo.getUserByEmail(email);
    }

    public List<User> getAllUsers() {
        return userRepo.getAllUsers();
    }

    public Integer getIdByEmail(String email) {
        User user = userRepo.getUserByEmail(email);
        if (user == null) {
            return null;
        }
        return user.getId();
    }

    public String verify(User user) {
        Authentication authentication =
                authManager.authenticate(new UsernamePasswordAuthenticationToken(user.getEmail(), user.getPassword()));

        User existingUser = getUserByEmail(user.getEmail());
        System.out.println("Exisiting user isVerified: " + existingUser.isVerified());
        if (existingUser == null || !existingUser.isVerified()) {
            return "FAIL";
        }

        if(authentication.isAuthenticated()) {
            Integer id = getIdByEmail(user.getEmail());
            if (id == null) {
                return "FAIL";
            }
            return jwtService.generateToken(id);
        }

        return "FAIL";
    }
}
