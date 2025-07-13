package com.ftracker.server.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.ftracker.server.enums.HeadCategoryType;
import jakarta.persistence.*;

@Entity
@Table(name = "category")
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "head_category")
    private HeadCategoryType headCategory;

    @Column(name = "name")
    private String name;

    @ManyToOne
    @JoinColumn(name = "user_id")
    @JsonIgnore
    private User user;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public HeadCategoryType getHeadCategory() {
        return headCategory;
    }

    public void setHeadCategory(HeadCategoryType headCategory) {
        this.headCategory = headCategory;
    }
}
