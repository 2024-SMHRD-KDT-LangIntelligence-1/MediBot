package com.fiveit.medibot.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "users")
public class User implements UserDetails { // UserDetails 구현 추가

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // 자동 증가 (PK)

    @Column(nullable = false, unique = true)
    private String userid; // 아이디 (유니크)

    public String getUserid() {
        return userid;
    }

    @Column(nullable = false)
    private String password; // 암호화된 비밀번호

    @Column(nullable = false)
    private String username; // 사용자 이름

    @Column(nullable = false)
    private LocalDate birthdate; // 생년월일

    @Column(nullable = false)
    private int age;

    @Column(nullable = false)
    private String gender; // 성별 (예: M, F)

    private LocalTime wakeUpTime; // 기상 시간
    private LocalTime sleepTime; // 취침 시간

    @ElementCollection
    @CollectionTable(name = "medication_schedule", joinColumns = @JoinColumn(name = "user_id"))
    private List<MedicationTime> medicationtTimes; // 약 복용 일정

    // Spring Security의 UserDetails 인터페이스 메서드 구현
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.emptyList(); // 권한이 필요하면 수정 가능
    }

    @Override
    public boolean isAccountNonExpired() {
        return true; // 계정 만료 여부 (true = 만료되지 않음)
    }

    @Override
    public boolean isAccountNonLocked() {
        return true; // 계정 잠금 여부 (true = 잠금되지 않음)
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true; // 비밀번호 만료 여부 (true = 만료되지 않음)
    }

    @Override
    public boolean isEnabled() {
        return true; // 계정 활성화 여부 (true = 활성화됨)
    }
}