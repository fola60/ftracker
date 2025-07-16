package com.ftracker.server.dto;

import com.ftracker.server.enums.HeadCategoryType;

public class CategoryRequest {
    private Integer id;
    private HeadCategoryType head_category;
    private String name;
    private Integer user_id;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public HeadCategoryType getHead_category() {
        return head_category;
    }

    public void setHead_category(HeadCategoryType head_category) {
        this.head_category = head_category;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getUser_id() {
        return user_id;
    }

    public void setUser_id(Integer user_id) {
        this.user_id = user_id;
    }
}
