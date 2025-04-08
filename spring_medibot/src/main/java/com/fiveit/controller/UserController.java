package com.fiveit.controller;

import com.fiveit.dto.LoginRequest;
import com.fiveit.dto.SignUpRequest;
import com.fiveit.model.User;
import com.fiveit.Service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.Period;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    private int calculateAge(LocalDate birthDate) {
        return Period.between(birthDate, LocalDate.now()).getYears();
    }

    private String convertGender(String gender) {
        if (gender.equalsIgnoreCase("M"))
            return "남성";
        else if (gender.equalsIgnoreCase("F"))
            return "여성";
        else
            return "기타";
    }

    // 회원가입 API
    @PostMapping("/signup")
    public ResponseEntity<String> signUp(@RequestBody SignUpRequest request) {
        try {
            User newUser = userService.registerUser(request);
            return ResponseEntity.ok(newUser.getUserId());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 사용자 정보 조회 API
    @GetMapping("/info/{userId}")
    public ResponseEntity<?> getUserInfo(@PathVariable String userId) {
        User user = userService.findUserByUserId(userId);

        int age = Period.between(user.getBirthdate(), LocalDate.now()).getYears();

        return ResponseEntity.ok(Map.of(
                "age", age,
                "gender", user.getGender() // 자동으로 "남성", "여성"으로 변환됨
        ));
    }

    // 이메일 중복 확인 API
    @GetMapping("/check-duplicate")
    public ResponseEntity<?> checkDuplicate(@RequestParam String userId) {
        boolean isDuplicate = userService.isUserIdDuplicate(userId);
        return ResponseEntity.ok().body(Map.of("duplicate", isDuplicate));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        User user = userService.authenticateUser(request.getUserId(), request.getPassword());

        if (user != null) {
            return ResponseEntity.ok("로그인 성공: " + user.getUserId());
        } else {
            return ResponseEntity.badRequest().body("로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.");
        }
    }

    // 회원 탈퇴 API
    @DeleteMapping("/delete/{userId}")
    public ResponseEntity<String> deleteUser(@PathVariable String userId) {
        try {
            System.out.println("deleteUser: " + userId);
            userService.deleteUserById(userId);
            return ResponseEntity.ok("회원 탈퇴가 완료되었습니다.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("탈퇴 실패: " + e.getMessage());
        }
    }
}