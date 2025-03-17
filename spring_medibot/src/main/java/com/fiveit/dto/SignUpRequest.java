package com.fiveit.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SignUpRequest {
    private String userId;
    private String username;
    private String password;
    private String birthdate; // "YYYY-MM-DD" 문자열로 받음
    private Integer age;
    private String gender;
    private String wakeUpTime; // "HH:mm:ss" 문자열
    private String sleepTime;
}