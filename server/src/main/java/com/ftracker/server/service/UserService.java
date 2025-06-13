package com.ftracker.server.service;

import com.ftracker.server.entity.User;
import com.ftracker.server.repo.UserRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    UserRepo userRepo;

    public User getUserById(Integer id) {
        return userRepo.getUserById(id);
    }
}
