package com.itwillbs.repository;

import com.itwillbs.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // username으로 사용자 찾기
    Optional<User> findByUsername(String username);
    
    // email로 사용자 찾기
    Optional<User> findByEmail(String email);
    
    // username이 존재하는지 확인
    boolean existsByUsername(String username);
    
    // email이 존재하는지 확인
    boolean existsByEmail(String email);
    
    // 사용자명에 특정 문자열이 포함된 사용자들 찾기
    @Query("SELECT u FROM User u WHERE u.username LIKE %:keyword%")
    java.util.List<User> findByUsernameContaining(@Param("keyword") String keyword);
}