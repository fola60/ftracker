package com.ftracker.server.service;

import com.ftracker.server.dto.IncomeRequest;
import com.ftracker.server.entity.Income;
import com.ftracker.server.entity.User;
import com.ftracker.server.repo.IncomeRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class IncomeService {

    @Autowired
    private IncomeRepo incomeRepo;

    @Autowired
    private UserService userService;

    public List<Income> getAllIncomeById(Integer id) {
        return incomeRepo.getAllIncomeById(id);
    }

    public Optional<Income> getIncomeById(Integer id) {
        return incomeRepo.findById(id);
    }

    public void saveIncome(IncomeRequest incomeRequest) {
        Income income = new Income();
        User user = userService.getUserById(incomeRequest.getUser_id());

        income.setDescription(incomeRequest.getDescription());
        income.setAmount(incomeRequest.getAmount());
        income.setType(incomeRequest.getType());
        income.setName(incomeRequest.getName());
        income.setTime(LocalDateTime.now());
        user.getIncomes().add(income);
        income.setUser(user);

        incomeRepo.save(income);
    }

    public void deleteIncome(Integer id) {
        incomeRepo.deleteIncomeById(id);
    }
}
