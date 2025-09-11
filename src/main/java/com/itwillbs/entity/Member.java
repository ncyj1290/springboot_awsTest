package com.itwillbs.entity;

import groovy.transform.Generated;
import groovy.transform.ToString;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

// @Entity : 클래스 엔티티 선언
// @Table : 엔티티와 매핑할 테이블 지정
// @Id : 테이블에서 기본키 사용할 속성 지정
// @Column : 필드와 컬럼 매핑
// name = "컬럼명", length = 크기, nullable = false, unique,
//	columnDeinition=varchar(5) 직접지정, insertable, updatalbe
//@GeneratedValue(strategy=GenerationType.AUTO) 키값생성, 자동으로 증가
//@Lob bLob, CLOB 타입매핑
//@CreateTimestamp insert 시간 자동 저장
//@Enumerated enum 타입매핑

@Entity
@Table(name = "members")
@Getter
@Setter
@ToString
public class Member {
	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "idx")
	private int idx;
	
	@Column(name = "name", nullable = false)
	private String name;
	
	@Column(name = "id", length = 50)
	private String id;
	
	@Column(name = "passwd", nullable = false)
	private String passwd;
	
}
