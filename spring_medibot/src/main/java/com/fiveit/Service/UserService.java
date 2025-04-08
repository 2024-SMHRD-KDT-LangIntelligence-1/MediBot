package com.fiveit.Service;

import com.fiveit.dto.SignUpRequest;
import com.fiveit.model.Gender;
import com.fiveit.model.User;
import com.fiveit.repository.MedicationScheduleRepository;
import com.fiveit.repository.UserRepository;

import jakarta.transaction.Transactional;

import org.springframework.stereotype.Service;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Date;
import java.util.Optional;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder(); // 🔐 추가
    private final MedicationScheduleRepository scheduleRepository;

    public UserService(UserRepository userRepository, MedicationScheduleRepository scheduleRepository) {
        this.userRepository = userRepository;
        this.scheduleRepository = scheduleRepository;
    }

    public User registerUser(SignUpRequest request) {
        // 이메일 중복 체크
        if (userRepository.findByUserId(request.getUserId()).isPresent()) {
            throw new IllegalArgumentException("이미 사용 중인 이메일입니다.");
        }
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        // 데이터 변환 (String → LocalDate, LocalTime, Enum)
        LocalDate birthDate = (request.getBirthdate() != null && !request.getBirthdate().isEmpty())
                ? LocalDate.parse(request.getBirthdate())
                : null;
        LocalTime wakeUpTime = request.getWakeUpTime() != null ? LocalTime.parse(request.getWakeUpTime()) : null;
        LocalTime sleepTime = request.getSleepTime() != null ? LocalTime.parse(request.getSleepTime()) : null;
        Gender gender = (request.getGender() != null && !request.getGender().isEmpty())
                ? Gender.valueOf(request.getGender())
                : null; // "M" 또는 "F"를 ENUM으로
                        // 변환

        // 사용자 저장 (비밀번호 암호화 제거)
        User user = User.builder()
                .userId(request.getUserId())
                .userName(request.getUsername())
                .userPw(encodedPassword) // ✅ 암호화된 비밀번호 저장
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
            if (passwordEncoder.matches(password, user.getUserPw())) {
                return user;
            }
        }
        return null; // ❌ 인증 실패 시 null 반환
    }

    public boolean isUserIdDuplicate(String userId) {
        return userRepository.findByUserId(userId).isPresent();
    }

    @Transactional
    public void deleteUserById(String userId) {
        // 1. 사용자 존재 확인
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("해당 사용자를 찾을 수 없습니다."));

        // 2. 먼저 복약 일정 삭제
        scheduleRepository.deleteAllByUserId(userId); // <- 이 메서드 추가 필요

        // 3. 사용자 삭제
        userRepository.delete(user);
    }

    public User findUserByUserId(String userId) {
        return userRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
    }
}