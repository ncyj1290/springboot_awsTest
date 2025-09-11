package com.itwillbs.Service;

import org.springframework.stereotype.Service;

import com.itwillbs.vo.MemberVO;

import lombok.extern.java.Log;

@Service
@Log
public class MemberService {
	
	public void save(MemberVO member) {
		log.info("MemberService save()");
		log.info(member.toString());
	}
}
