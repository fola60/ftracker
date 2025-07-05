package com.ftracker.server.controller;

import com.ftracker.server.dto.RecurringRevenueRequest;
import com.ftracker.server.entity.User;
import com.ftracker.server.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    UserService userService;

    @PostMapping("/post-user")
    public void postUser(@Validated @RequestBody User user) {
        userService.saveUser(user);
    }

    @GetMapping("/get-user/{id}")
    public User getUserById(@PathVariable Integer id) {
        return userService.getUserById(id);
    }
}
