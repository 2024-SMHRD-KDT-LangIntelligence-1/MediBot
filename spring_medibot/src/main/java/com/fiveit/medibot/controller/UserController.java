package com.fiveit.medibot.controller;

import com.fiveit.medibot.dto.UserRegisterDTO;
import com.fiveit.medibot.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/auth")
public class UserController {

    private final UserService userService;

    // 회원가입 API
    @PostMapping("/signup")
    public ResponseEntity<String> signUp(@RequestBody UserRegisterDTO request) {
        Long userId = userService.saveUser(request);

        if (userId == null) { // 아이디(이메일) 중복 확인 → 가입 불가
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("이미 사용 중인 아이디입니다.");
        } else { // 정상 가입 완료
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body("회원가입 완료 (ID: " + userId + ")");
        }
    }

    // 로그아웃 API
    @GetMapping("/logout")
    public ResponseEntity<String> logout(HttpServletRequest request, HttpServletResponse response) {
        new SecurityContextLogoutHandler().logout(request, response,
                SecurityContextHolder.getContext().getAuthentication());
        return ResponseEntity.ok()
                .body("로그아웃 완료");
    }
}