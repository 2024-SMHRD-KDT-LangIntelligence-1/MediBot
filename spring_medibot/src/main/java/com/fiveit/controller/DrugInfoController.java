package com.fiveit.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.fiveit.Service.DrugInfoService;
import com.fiveit.Service.MedicationScheduleService;
import com.fiveit.dto.MedicationScheduleRequestDTO;
import com.fiveit.dto.UpdateTimeRequest;
import com.fiveit.model.DrugInfo;
import com.fiveit.model.MedicationSchedule;
import com.fiveit.repository.DrugInfoRepository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/drug-info")
public class DrugInfoController {

    private final DrugInfoService drugInfoService;

    // DrugInfoRepository 필드를 추가합니다.
    private final DrugInfoRepository drugInfoRepository;

    // 생성자 주입
    public DrugInfoController(DrugInfoService drugInfoService, DrugInfoRepository drugInfoRepository) {
        this.drugInfoService = drugInfoService;
        this.drugInfoRepository = drugInfoRepository;
    }

    @GetMapping("/search")
    public ResponseEntity<List<String>> searchDrugs(@RequestParam(required = false) String name) {
        List<DrugInfo> results;

        if (name != null && !name.isEmpty()) {
            results = drugInfoService.searchByNameOrCategory(name);
        } else {
            results = drugInfoService.getAll();
        }

        List<String> drugNames = results.stream()
                .map(DrugInfo::getMediName)
                .distinct()
                .toList();

        return ResponseEntity.ok(drugNames);
    }

    @GetMapping("/detail")
    public ResponseEntity<List<DrugInfo>> getDrugInfoDetail(@RequestParam String name) {
        List<DrugInfo> result = drugInfoRepository.findByMediNameContainingIgnoreCase(name);
        return ResponseEntity.ok(result);
    }
}