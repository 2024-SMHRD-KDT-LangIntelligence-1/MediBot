package com.fiveit.medibot.service;

import com.fiveit.medibot.dto.UserRegisterDTO;
import com.fiveit.medibot.entity.User;
import com.fiveit.medibot.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@RequiredArgsConstructor
@Service
@Transactional
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder; // DI 방식으로 PasswordEncoder 사용

    // 아이디 기반 사용자 정보 조회 (스프링 시큐리티)
    @Override
    public UserDetails loadUserByUsername(String userid) throws UsernameNotFoundException {
        User user = userRepository.findByUserid(userid) // 수정: findByUserID → findByUserid
                .orElseThrow(() -> new UsernameNotFoundException("존재하지 않는 아이디 : " + userid));

        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getUserid()) // 수정: user.getUsername() → user.getUserid()
                .password(user.getPassword())
                .roles("USER") // 기본 권한 부여
                .build();
    }

    // 아이디 기반 사용자 조회
    public User findByUserid(String userid) { // 수정: findByUserID → findByUserid
        return userRepository.findByUserid(userid) // 수정: findByUserID(userid) → findByUserid(userid)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 아이디 : " + userid));
    }

    // 회원가입 (비밀번호 암호화 & 중복 체크)
    public Long saveUser(UserRegisterDTO request) {
        // 아이디(이메일) 중복 확인
        if (userRepository.existsByUserid(request.getUserid())) {
            throw new IllegalArgumentException("이미 사용 중인 아이디입니다.");
        }
        // 비밀번호 암호화 적용
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        // 사용자 엔티티 생성 및 저장
        User newUser = User.builder()
                .userid(request.getUserid())
                .password(encodedPassword) // 비밀번호 암호화
                .username(request.getUsername())
                .birthdate(request.getBirthdate())
                .gender(request.getGender())
                .age(request.getAge()) // 나이 저장
                .wakeUpTime(request.getWakeUpTime())
                .sleepTime(request.getSleepTime())
                .build();

        return userRepository.save(newUser).getId();
    }
}