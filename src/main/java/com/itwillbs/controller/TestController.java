package com.itwillbs.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class TestController {
	
	@GetMapping("test")
	public String test() {
		return "test";
	}
	
	@GetMapping("test1")
	public String test1() {
		return "test1";
	}
	
	@GetMapping("test2")
	public String test2() {
		return "test2";
	}
	
	@GetMapping("test3")
	public String test3(Model model) {
		
		return "test3";
	}
	
	@GetMapping("test4")
	public String test4(@RequestParam Map<String, String> params, Model model) {
		model.addAttribute("member", params);
		
		List<String> tempList = new ArrayList<>();
		tempList.add("홍길동1");
		tempList.add("홍길동2");
		tempList.add("홍길동3");
		tempList.add("홍길동4");
		tempList.add("홍길동5");
		
		model.addAttribute("tempList", tempList);
		
		return "test4";
	}
	
	
}
