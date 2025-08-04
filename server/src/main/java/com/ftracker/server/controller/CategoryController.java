package com.ftracker.server.controller;

import com.ftracker.server.dto.CategoryRequest;
import com.ftracker.server.entity.Budget;
import com.ftracker.server.entity.Category;
import com.ftracker.server.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/category")
public class CategoryController {

    @Autowired
    private CategoryService categoryService;

    @GetMapping("/get-by-user-id/{id}")
    public List<Category> getByUserId(@PathVariable Integer id) {
        return categoryService.getCategoryByUserId(id);
    }

    @PostMapping("/post")
    public Category save(@Validated @RequestBody CategoryRequest categoryRequest) {
        return categoryService.saveCategory(categoryRequest);
    }


    @DeleteMapping("/delete/{id}")
    public boolean delete(Integer id) {
        return categoryService.deleteCategory(id);
    }

}
