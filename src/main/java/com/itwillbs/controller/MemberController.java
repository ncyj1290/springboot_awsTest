package com.itwillbs.controller;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

import com.itwillbs.Service.MemberService;
import com.itwillbs.vo.MemberVO;

import lombok.RequiredArgsConstructor;
import lombok.extern.java.Log;

@Controller
@Log
@RequiredArgsConstructor
public class MemberController {

	private final MemberService memberService;
	
	
	@GetMapping("insert")
	public String insert() {
		return "member/insert";
	}
	
	@PostMapping("insertPro")
	public String insertPro(MemberVO member) {
		log.info("MemberController insertPro()");
		log.info(member.toString());
		
		memberService.save(member);
		
		return "redirect:/login";
	}
	
	@GetMapping("login")
	public String login() {
		return "member/login";
	}
}
