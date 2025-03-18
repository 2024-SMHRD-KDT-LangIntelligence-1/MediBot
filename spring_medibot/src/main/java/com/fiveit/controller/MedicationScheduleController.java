package com.fiveit.controller;

import com.fiveit.dto.MedicationScheduleDto;
import com.fiveit.model.MedicationSchedule;
import com.fiveit.Service.MedicationScheduleService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/schedules")
public class MedicationScheduleController {

    private final MedicationScheduleService scheduleService;

    public MedicationScheduleController(MedicationScheduleService scheduleService) {
        this.scheduleService = scheduleService;
    }

    // 1. 복약 일정 등록 API
    @PostMapping
    public ResponseEntity<MedicationSchedule> createSchedule(@RequestBody MedicationScheduleDto dto) {
        MedicationSchedule schedule = scheduleService.createSchedule(dto);
        return ResponseEntity.ok(schedule);
    }

    // 2. 특정 날짜의 복약 일정 조회 API
    @GetMapping("/{userId}/{date}")
    public ResponseEntity<List<MedicationSchedule>> getSchedules(@PathVariable String userId,
            @PathVariable String date) {
        LocalDate localDate = LocalDate.parse(date);
        List<MedicationSchedule> schedules = scheduleService.getSchedulesByUserAndDate(userId, localDate);
        return ResponseEntity.ok(schedules);
    }
}