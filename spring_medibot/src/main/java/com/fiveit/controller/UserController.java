package com.fiveit.controller;

import com.fiveit.dto.SignUpRequest;
import com.fiveit.model.User;
import com.fiveit.Service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    // 회원가입 API
    @PostMapping("/signup")
    public ResponseEntity<String> signUp(@RequestBody SignUpRequest request) {
        try {
            User newUser = userService.registerUser(request);
            return ResponseEntity.ok("회원가입 성공: " + newUser.getUserId());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 이메일 중복 확인 API
    @GetMapping("/check-email")
    public ResponseEntity<Boolean> checkEmail(@RequestParam String userId) {
        boolean exists = userService.checkEmailExists(userId);
        return ResponseEntity.ok(exists);
    }
}