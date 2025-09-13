package com.itwillbs.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/user")
public class UserViewController {
    
    // 사용자 목록 페이지
    @GetMapping("/list")
    public String userList() {
        return "user/list";
    }
    
    // 사용자 등록 페이지
    @GetMapping("/register")
    public String userRegister() {
        return "user/register";
    }
    
    // 사용자 수정 페이지
    @GetMapping("/edit/{id}")
    public String userEdit(@PathVariable Long id) {
        return "user/edit";
    }
}