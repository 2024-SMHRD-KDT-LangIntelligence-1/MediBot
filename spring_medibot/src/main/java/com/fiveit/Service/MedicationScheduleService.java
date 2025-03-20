package com.fiveit.Service;

import com.fiveit.dto.MedicationScheduleRequestDTO;
import com.fiveit.model.MedicationSchedule;
import com.fiveit.repository.MedicationScheduleRepository;

import jakarta.transaction.Transactional;

import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
// import java.util.Optional;

@Service
public class MedicationScheduleService {

    private final MedicationScheduleRepository medicationScheduleRepository;

    public MedicationScheduleService(MedicationScheduleRepository medicationScheduleRepository) {
        this.medicationScheduleRepository = medicationScheduleRepository;
    }

    // ✅ 약 복용 스케줄 저장
    @Transactional
    public MedicationSchedule saveSchedule(MedicationScheduleRequestDTO dto) {
        MedicationSchedule schedule = new MedicationSchedule();

        // ✅ 문자열 날짜/시간을 LocalDate 및 LocalTime으로 변환 (만약 엔티티가 LocalDate 사용한다면)
        schedule.setTmDate(LocalDate.parse(dto.getTmDate())); // YYYY-MM-DD
        schedule.setTmTime(LocalTime.parse(dto.getTmTime())); // HH:mm

        // ✅ "Y" / "N" 값을 boolean으로 변환
        schedule.setTmDone(dto.getTmDone().equalsIgnoreCase("Y"));

        // ✅ realTmAt가 null이 아닐 때만 변환
        schedule.setRealTmAt(dto.getRealTmAt());

        // ✅ userId & 약 이름 그대로 매핑
        schedule.setUserId(dto.getUserId());
        schedule.setMediName(dto.getMediName());

        return medicationScheduleRepository.save(schedule);
    }

    // ✅ 특정 유저의 스케줄 조회
    public List<MedicationSchedule> getSchedulesByUser(String userId, String date) {
        List<MedicationSchedule> schedules = medicationScheduleRepository.findByUserId(userId);

        if (date != null) {
            return schedules.stream()
                    .filter(schedule -> schedule.getTmDate().toString().equals(date)) // ✅ 날짜 필터링
                    .collect(Collectors.toList());
        }

        return schedules;
    }

    public List<MedicationSchedule> getSchedulesByUserAndDate(String userId, String date) {
        return medicationScheduleRepository.findByUserIdAndTmDate(userId, LocalDate.parse(date));
    }

    @Transactional
    public void updateMedicationStatus(String userId, String mediName, String tmDate, boolean tmDone) {
        // ✅ String을 LocalDate로 변환
        LocalDate date = LocalDate.parse(tmDate, DateTimeFormatter.ofPattern("yyyy-MM-dd"));

        List<MedicationSchedule> schedules = medicationScheduleRepository.findAllByUserIdAndMediNameAndTmDate(userId,
                mediName, date);

        if (schedules.isEmpty()) {
            throw new RuntimeException("🚨 해당 날짜의 복약 기록을 찾을 수 없음");
        }

        for (MedicationSchedule schedule : schedules) {
            // ✅ tmDone이 true이면 realTmAt을 현재 시간(LocalDateTime)으로 설정
            schedule.setTmDone(tmDone);

            if (tmDone) {
                schedule.setRealTmAt(LocalTime.now());
            } else {
                schedule.setRealTmAt(null); // 체크 해제 시 null로 초기화
            }
            medicationScheduleRepository.save(schedule);

        }
    }
}