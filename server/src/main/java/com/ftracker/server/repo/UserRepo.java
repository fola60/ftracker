package com.ftracker.server.repo;

import com.ftracker.server.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepo extends JpaRepository<User, Integer> {
    @Query(value = "SELECT * FROM user_table where id = :id", nativeQuery = true)
    public User getUserById(Integer id);

    @Query(value = "SELECT * FROM user_table WHERE email = :email", nativeQuery = true)
    public User getUserByEmail(String email);
}
