package com.fiveit.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.fiveit.Service.MedicationScheduleService;
import com.fiveit.dto.MedicationScheduleRequestDTO;
import com.fiveit.dto.UpdateTimeRequest;
import com.fiveit.model.MedicationSchedule;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/medication-schedules")
public class MedicationScheduleController {

    private final MedicationScheduleService medicationScheduleService;

    public MedicationScheduleController(MedicationScheduleService medicationScheduleService) {
        this.medicationScheduleService = medicationScheduleService;
    }

    // ✅ 복용 스케줄 저장 (POST)
    @PostMapping
    public ResponseEntity<MedicationSchedule> saveSchedule(@RequestBody MedicationScheduleRequestDTO dto) {
        MedicationSchedule savedSchedule = medicationScheduleService.saveSchedule(dto);
        System.out.println("📩 받은 요청 데이터: " + savedSchedule); // 🔥 요청된 데이터 로그 출력

        return ResponseEntity.ok(savedSchedule);
    }

    // ✅ 특정 유저의 스케줄 조회 (GET)
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<MedicationSchedule>> getSchedulesByUser(@PathVariable String userId,
            @RequestParam(required = false) String date) {
        System.out.println("📩 받은 요청 데이터: " + userId + ", " + date); // 🔥 요청된 데이터 로그
        // 출력

        List<MedicationSchedule> schedules;

        // if (date != null && !date.isEmpty()) {
        schedules = medicationScheduleService.getSchedulesByUserAndDate(userId, date);
        // } // else {
        // schedules = medicationScheduleService.getSchedulesByUser(userId);
        // }
        System.out.println("📩 받은 요청 데이터: " + schedules); // 🔥 요청된 데이터 로그 출력
        return ResponseEntity.ok(schedules);
    }

    // ✅ 특정 스케줄 조회 (GET)
    // @GetMapping("/{tmIdx}")
    // public ResponseEntity<Optional<MedicationSchedule>>
    // getScheduleById(@PathVariable Long tmIdx) {
    // Optional<MedicationSchedule> schedule =
    // medicationScheduleService.getScheduleById(tmIdx);
    // return ResponseEntity.ok(schedule);
    // }

    @PutMapping("/update")
    public ResponseEntity<String> updateMedicationStatus(@RequestBody Map<String, Object> request) {
        String userId = (String) request.get("userId");
        String mediName = (String) request.get("mediName");
        String tmDate = (String) request.get("tmDate"); // ✅ 날짜 추가
        boolean tmDone = (Boolean) request.get("tmDone");
        System.out.println(userId);

        medicationScheduleService.updateMedicationStatus(userId, mediName, tmDate, tmDone);
        return ResponseEntity.ok("✅ 복약 상태 업데이트 완료");
    }

    // ✅ 특정 약 + 시간에 대한 복용일자 조회
    @GetMapping("/dates")
    public ResponseEntity<?> getMedicationDateRange(
            @RequestParam String userId,
            @RequestParam String mediName,
            @RequestParam String tmTime) {
        try {
            // ✅ "HH:mm:ss" 형식의 String → LocalTime 변환
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
            LocalTime parsedTime = LocalTime.parse(tmTime, formatter);

            // ✅ 변환된 LocalTime을 사용하여 서비스 호출
            Map<String, String> dateRange = medicationScheduleService.getMedicationDateRange(userId, mediName,
                    parsedTime);

            return ResponseEntity.ok(dateRange);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("🚨 복용일자 조회 실패: " + e.getMessage());
        }
    }

    // ✅ 특정 약 삭제 (같은 약 전체 삭제)
    @DeleteMapping("/delete")
    public ResponseEntity<?> deleteMedication(
            @RequestParam String userId,
            @RequestParam String mediName,
            @RequestParam String tmTime) {
        try {
            // ✅ String → LocalTime 변환 (포맷: "HH:mm:ss")
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
            LocalTime parsedTime = LocalTime.parse(tmTime, formatter);

            // ✅ 변환된 LocalTime을 사용하여 서비스 호출
            medicationScheduleService.deleteMedication(userId, mediName, parsedTime);
            return ResponseEntity.ok("✅ 복약 일정 삭제 성공 (약: " + mediName + ", 시간: " + tmTime + ")");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("🚨 복약 일정 삭제 실패: " + e.getMessage());
        }
    }

    @PostMapping("/update-time")
    public ResponseEntity<?> updateMedicationTime(@RequestBody UpdateTimeRequest request) {
        // System.out.println("📡 요청 들어옴: " + request);

        try {
            // ✅ 문자열을 LocalTime으로 변환
            LocalTime oldTime = LocalTime.parse(request.getOldTime());
            LocalTime newTime = LocalTime.parse(request.getNewTime());

            // ✅ Service 호출 (변환된 LocalTime 전달)
            medicationScheduleService.updateMedicationTime(
                    request.getUserId(),
                    request.getMediName(),
                    oldTime,
                    newTime);

            return ResponseEntity.ok("✅ 복약 시간 수정 완료");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("🚨 복약 시간 수정 실패: " + e.getMessage());
        }
    }
}
