package com.fiveit.Service;

import com.fiveit.dto.SignUpRequest;
import com.fiveit.model.Gender;
import com.fiveit.model.User;
import com.fiveit.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Date;
import java.util.Optional;

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User registerUser(SignUpRequest request) {
        // 이메일 중복 체크
        if (userRepository.findByUserId(request.getUserId()).isPresent()) {
            throw new IllegalArgumentException("이미 사용 중인 이메일입니다.");
        }

        // 데이터 변환 (String → LocalDate, LocalTime, Enum)
        LocalDate birthDate = LocalDate.parse(request.getBirthdate());
        LocalTime wakeUpTime = request.getWakeUpTime() != null ? LocalTime.parse(request.getWakeUpTime()) : null;
        LocalTime sleepTime = request.getSleepTime() != null ? LocalTime.parse(request.getSleepTime()) : null;
        Gender gender = Gender.valueOf(request.getGender()); // "M" 또는 "F"를 ENUM으로 변환

        // 사용자 저장 (비밀번호 암호화 제거)
        User user = User.builder()
                .userId(request.getUserId())
                .userName(request.getUsername())
                .userPw(request.getPassword()) // 🔥 평문 저장 (보안 취약)
                .birthdate(birthDate)
                // .age(request.getAge())
                .gender(gender)
                .wakeupTm(request.getWakeUpTime()) // ✅ 필드명 변경 (wakeUpTime → wakeupTm)
                .gotobedTm(request.getSleepTime())
                // ✅ 필드명 변경 (sleepTime → gotobedTm)
                .build();

        user.setJoinedAt(new Date()); // 가입 날짜를 현재 시간으로 설정

        return userRepository.save(user);
    }

    public User authenticateUser(String userId, String password) {
        Optional<User> userOpt = userRepository.findById(userId);

        if (userOpt.isPresent()) {
            User user = userOpt.get();

            // ✅ 저장된 비밀번호와 입력된 비밀번호 단순 비교
            if (user.getUserPw().equals(password)) {
                return user; // ✅ 인증 성공
            }
        }
        return null; // ❌ 인증 실패 시 null 반환
    }

    public boolean checkEmailExists(String userId) {
        return userRepository.findByUserId(userId).isPresent();
    }
}