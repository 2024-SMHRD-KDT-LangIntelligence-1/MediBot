package com.fiveit.Service;

import com.fiveit.dto.MedicationScheduleRequestDTO;
import com.fiveit.model.DrugInfo;
import com.fiveit.model.MedicationSchedule;
import com.fiveit.repository.DrugInfoRepository;
import com.fiveit.repository.MedicationScheduleRepository;

import jakarta.transaction.Transactional;

import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
// import java.util.Optional;
import java.util.Map;

@Service
public class DrugInfoService {

    private final DrugInfoRepository drugInfoRepository;

    public DrugInfoService(DrugInfoRepository drugInfoRepository) {
        this.drugInfoRepository = drugInfoRepository;
    }

    public List<DrugInfo> searchByName(String name) {
        String[] keywords = name.trim().split("\\s+");

        if (keywords.length == 1) {
            return drugInfoRepository.findByMediNameContainingIgnoreCase(keywords[0]);
        } else if (keywords.length >= 2) {
            return drugInfoRepository.searchByTwoKeywords(keywords[0], keywords[1]);
        } else {
            return List.of();
        }
    }

    public List<DrugInfo> searchByCategory(String category) {
        String[] keywords = category.trim().split("\\s+");

        if (keywords.length == 1) {
            return drugInfoRepository.findByCategoryContainingIgnoreCase(keywords[0]);
        } else if (keywords.length >= 2) {
            return drugInfoRepository.searchCategoryByTwoKeywords(keywords[0], keywords[1]);
        } else {
            return List.of();
        }
    }

    public List<DrugInfo> searchByNameOrCategory(String keyword) {
        return drugInfoRepository.findByMediNameContainingIgnoreCaseOrCategoryContainingIgnoreCase(keyword, keyword);
    }

    public List<DrugInfo> getAll() {
        return drugInfoRepository.findAll();
    }
}