package com.fiveit.repository;

import com.fiveit.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, String> {
    Optional<User> findByUserId(String userId); // 아이디(이메일) 중복 체크
}