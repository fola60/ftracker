package com.ftracker.server.service;

import com.ftracker.server.dto.CategoryRequest;
import com.ftracker.server.entity.Category;
import com.ftracker.server.entity.User;
import com.ftracker.server.repo.CategoryRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {
    @Autowired
    private CategoryRepo categoryRepo;

    @Autowired
    private UserService userService;

    public boolean deleteCategory(Integer categoryId) {
        // TODO: implement on delete set null
        categoryRepo.deleteByCategoryId(categoryId);
        return true;
    }

    public Category getCategoryById(Integer categoryId) {
        return categoryRepo.getCategoryById(categoryId);
    }

    public boolean saveCategory(CategoryRequest categoryRequest) {
        Category category = new Category();
        User user = userService.getUserById(categoryRequest.getUser_id());

        if (inUserCategories(categoryRequest.getUser_id(), categoryRequest.getName())) {
            return false;
        }

        if (categoryRequest.getId() == null) {
            categoryRequest.setId(categoryRequest.getId());
        }

        category.setHeadCategory(categoryRequest.getHead_category());
        category.setName(categoryRequest.getName());
        category.setUser(user);

        categoryRepo.save(category);
        user.getCategories().add(category);

        return true;
    }

    public boolean inUserCategories(Integer userId, String Category) {
        return categoryRepo.inUserCategory(userId, Category);
    }

    public List<Category> getCategoryByUserId(Integer id) {
        return categoryRepo.getByUserId(id);
    }


    public void save(Category category) {
        categoryRepo.save(category);
    }

}
