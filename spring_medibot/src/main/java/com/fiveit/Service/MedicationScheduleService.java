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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
// import java.util.Optional;
import java.util.Map;
import java.time.Duration;

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

    // ✅ 특정 약 + 시간의 복용일자 조회
    public Map<String, String> getMedicationDateRange(String userId, String mediName, LocalTime tmTime) {
        List<MedicationSchedule> schedules = medicationScheduleRepository.findByUserIdAndMediNameAndTmTime(userId,
                mediName, tmTime);

        if (schedules.isEmpty()) {
            throw new RuntimeException("해당 약의 복용일자가 존재하지 않습니다.");
        }

        List<String> sortedDates = schedules.stream()
                .map(s -> s.getTmDate().toString()) // ✅ toString() 변환 후 리스트로 변환
                .sorted() // ✅ 문자열 정렬
                .collect(Collectors.toList()); // 리스트 변환

        // ✅ 리스트의 첫 번째와 마지막 값을 저장
        String startDate = sortedDates.get(0);
        String endDate = sortedDates.get(sortedDates.size() - 1);

        Map<String, String> dateRange = new HashMap<>();
        dateRange.put("startDate", startDate);
        dateRange.put("endDate", endDate);

        // ✅ [디버깅] 최종 범위 출력
        // System.out.println("📡 시작 날짜: " + startDate);
        // System.out.println("📡 종료 날짜: " + endDate);

        return dateRange;
    }

    public void deleteMedication(String userId, String mediName, LocalTime tmTime) {
        List<MedicationSchedule> schedules = medicationScheduleRepository
                .findByUserIdAndMediNameAndTmTime(userId, mediName, tmTime); // ✅ LocalTime → String 유지

        if (schedules.isEmpty()) {
            throw new RuntimeException("삭제할 복약 일정이 존재하지 않습니다.");
        }

        medicationScheduleRepository.deleteAll(schedules);
    }

    public void updateMedicationTime(String userId, String mediName, LocalTime oldTmTime, LocalTime newTmTime) {
        List<MedicationSchedule> schedules = medicationScheduleRepository
                .findByUserIdAndMediNameAndTmTime(userId, mediName, oldTmTime); // ✅ LocalTime 제거

        if (schedules.isEmpty()) {
            throw new RuntimeException("수정할 복약 일정이 존재하지 않습니다.");
        }

        for (MedicationSchedule schedule : schedules) {
            // DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss"); // ✅
            // 시간 형식 지정
            // LocalTime parsedTime = LocalTime.parse(newTmTime, formatter); // ✅ String →
            // LocalTime 변환
            schedule.setTmTime(newTmTime); // ✅ LocalTime 저장
        }

        medicationScheduleRepository.saveAll(schedules);
    }

    public List<Map<String, Object>> analyzeMedicationPattern(String userId) {
        List<MedicationSchedule> schedules = medicationScheduleRepository.findByUserId(userId);

        List<Map<String, Object>> result = new ArrayList<>();

        for (MedicationSchedule schedule : schedules) {
            Map<String, Object> map = new HashMap<>();
            map.put("date", schedule.getTmDate());
            map.put("time", schedule.getTmTime().toString());
            map.put("mediName", schedule.getMediName()); // ✅ 약 이름 추가

            if (schedule.getRealTmAt() == null) {
                map.put("realTime", null);
                map.put("delay", -1);
                map.put("status", "미복용");
            } else {
                long delayMinutes = Duration.between(schedule.getTmTime(), schedule.getRealTmAt()).toMinutes();
                map.put("realTime", schedule.getRealTmAt().toString());
                map.put("delay", delayMinutes);

                String status;
                if (delayMinutes >= -20 && delayMinutes <= 20) {
                    status = "정상";
                } else if (Math.abs(delayMinutes) <= 30) {
                    status = "지연";
                } else {
                    status = "심각";
                }
                map.put("status", status);
            }
            result.add(map);
        }
        return result;
    }
}