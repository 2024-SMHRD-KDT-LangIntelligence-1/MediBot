package com.fiveit.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.fiveit.Service.MedicationScheduleService;
import com.fiveit.dto.MedicationScheduleRequestDTO;
import com.fiveit.model.MedicationSchedule;

import java.util.List;
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
    public ResponseEntity<List<MedicationSchedule>> getSchedulesByUser(@PathVariable String userId) {
        List<MedicationSchedule> schedules = medicationScheduleService.getSchedulesByUser(userId);
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
}