package com.fiveit.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String userId; // 아이디 (이메일)

    @Column(nullable = false, length = 50)
    private String username; // 이름

    @Column(nullable = false, length = 255)
    private String password; // 비밀번호

    @Column(nullable = false)
    private LocalDate birthdate; // 생년월일 (YYYY-MM-DD)

    @Column
    private Integer age; // 나이

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Gender gender; // 성별 (ENUM)

    @Column
    private LocalTime wakeUpTime; // 기상 시간

    @Column
    private LocalTime sleepTime; // 취침 시간

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt; // 가입일 (CURRENT_TIMESTAMP)

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

}
