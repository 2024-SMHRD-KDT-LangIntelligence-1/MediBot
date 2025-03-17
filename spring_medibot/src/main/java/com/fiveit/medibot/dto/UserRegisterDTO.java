package com.fiveit.medibot.dto;

import com.fiveit.medibot.entity.User;
import lombok.*;

import org.springframework.security.crypto.password.PasswordEncoder;
import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserRegisterDTO {
    private String userid; // 아이디

    public String getUserid() {
        return userid;
    }

    private String password; // 비밀번호
    private String username; // 이름
    private LocalDate birthdate; // 생년월일
    private String gender; // 성별 (남/여)
    private int age;
    private LocalTime wakeUpTime; // 기상 시간
    private LocalTime sleepTime; // 취침 시간

    // DTO → Entity 변환 (비밀번호 암호화 적용)
    public User toEntity(PasswordEncoder passwordEncoder) {
        return User.builder()
                .userid(this.userid)
                .password(passwordEncoder.encode(this.password)) // 비밀번호 암호화
                .username(this.username)
                .birthdate(this.birthdate)
                .gender(this.gender)
                .age(age)
                .wakeUpTime(this.wakeUpTime)
                .sleepTime(this.sleepTime)
                .build();
    }
}
