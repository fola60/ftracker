package com.ftracker.server.repo;

import com.ftracker.server.entity.Category;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CategoryRepo extends JpaRepository<Category, Integer> {

    @Modifying
    @Transactional
    @Query(value = "DELETE FROM category WHERE id = :id", nativeQuery = true)
    public int deleteByCategoryId(Integer id);

    @Query(value = "SELECT * FROM category WHERE id = :id", nativeQuery = true)
    public Category getCategoryById(Integer id);

    @Query(value = "SELECT * FROM category WHERE user_id = :userId", nativeQuery = true)
    public List<Category> getByUserId(Integer userId);

    @Query(value = "SELECT * FROM category WHERE user_id IS NULL", nativeQuery = true)
    public List<Category> getDefaultCategories();

    @Query(value = "SELECT COUNT(*) > 0 FROM category WHERE user_id = :userId AND name = :category", nativeQuery = true)
    boolean inUserCategory(Integer userId, String category);
}
