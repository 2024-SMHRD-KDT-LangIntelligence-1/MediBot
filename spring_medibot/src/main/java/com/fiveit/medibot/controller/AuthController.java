package com.fiveit.medibot.controller;

import com.fiveit.medibot.dto.JwtToken;
import com.fiveit.medibot.dto.UserRegisterDTO;
import com.fiveit.medibot.security.JwtTokenProvider;
import com.fiveit.medibot.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RequiredArgsConstructor
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final UserService userService;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;

    // 회원가입 API (JSON 형태로 응답)
    @PostMapping("/signup")
    public ResponseEntity<Map<String, Object>> signup(@RequestBody UserRegisterDTO request) {
        try {
            Long userId = userService.saveUser(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(
                    Map.of("message", "회원가입 성공!", "userId", userId));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    Map.of("message", e.getMessage()) // 중복 아이디 처리
            );
        }
    }

    // 로그인 API (JWT 발급)
    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> loginRequest) {
        String userid = loginRequest.get("userid"); // ✅ 필드명 수정 (username → userid)
        String password = loginRequest.get("password");

        try {
            // 사용자 인증
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(userid, password));

            // JWT 토큰 생성 (JwtToken 객체 반환)
            JwtToken jwtToken = jwtTokenProvider.generateToken(authentication);

            // JSON 응답 반환
            return ResponseEntity.ok(Map.of(
                    "message", "로그인 성공!",
                    "accessToken", jwtToken.getAccessToken(),
                    "refreshToken", jwtToken.getRefreshToken()));
        } catch (BadCredentialsException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    Map.of("message", "아이디 또는 비밀번호가 잘못되었습니다."));
        }
    }

    // JWT 토큰 검증 API
    @GetMapping("/validate-token")
    public ResponseEntity<Map<String, Object>> validateToken(@RequestHeader("Authorization") String token) {
        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }

        boolean isValid = jwtTokenProvider.validateToken(token);
        return isValid
                ? ResponseEntity.ok(Map.of("message", "토큰이 유효합니다."))
                : ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                        Map.of("message", "유효하지 않은 토큰입니다."));
    }
}
