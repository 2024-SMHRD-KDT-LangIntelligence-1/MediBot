package com.fiveit.controller;

import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import java.util.*;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    @PostMapping
    public ResponseEntity<?> chatWithFastAPI(@RequestBody Map<String, String> request) {
        String question = request.get("message");
        System.out.println(request.get("message"));

        String fastapiUrl = "http://112.217.124.195:30002/ask"; // ✅ FastAPI 주소

        try {
            RestTemplate restTemplate = new RestTemplate();

            // 헤더 설정
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            // 질문 JSON 구성
            Map<String, String> payload = new HashMap<>();
            payload.put("question", question);

            // HTTP 요청 생성
            HttpEntity<Map<String, String>> httpRequest = new HttpEntity<>(payload, headers);

            // POST 요청 → FastAPI
            ResponseEntity<Map> response = restTemplate.postForEntity(fastapiUrl, httpRequest, Map.class);

            System.out.println(response.getBody());
            // 응답 그대로 Flutter에 전달
            return ResponseEntity.ok(response.getBody());

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "FastAPI 연결 실패", "message", e.getMessage()));
        }
    }
}