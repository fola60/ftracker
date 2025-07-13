package com.ftracker.server.service;

import com.ftracker.server.entity.User;
import com.ftracker.server.entity.UserPrincipal;
import com.ftracker.server.repo.UserRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class MyUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepo repo;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = repo.getUserByEmail(email);

        if (user == null) {
            throw new UsernameNotFoundException("Email does not exist.");
        }

        UserPrincipal userPrincipal = new UserPrincipal();
        userPrincipal.setUser(user);

        return userPrincipal;
    }

    public UserDetails loadUserByUserId(Integer id) {
        User user = repo.getUserById(id);

        if (user == null) {
            throw new UsernameNotFoundException("Email does not exist.");
        }

        UserPrincipal userPrincipal = new UserPrincipal();
        userPrincipal.setUser(user);

        return userPrincipal;
    }
}
