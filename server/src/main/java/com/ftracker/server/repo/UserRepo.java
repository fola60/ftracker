package com.ftracker.server.repo;

import com.ftracker.server.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface UserRepo extends JpaRepository<User, Integer> {
    @Query(value = "SELECT * FROM user_table where id = :id", nativeQuery = true)
    public User getUserById(Integer id);

    @Query(value = "SELECT * FROM user_table WHERE email = :email", nativeQuery = true)
    public User getUserByEmail(String email);

    @Query(value = "SELECT * FROM user_table", nativeQuery = true)
    public List<User> getAllUsers();

    @Query(value = "SELECT * FROM user_table WHERE verification_token = :token", nativeQuery = true)
    public User findByVerificationToken(String token);

    @Query(value = "SELECT * FROM user_table WHERE reset_token = :token", nativeQuery = true)
    public User findByResetToken(String token);
}
