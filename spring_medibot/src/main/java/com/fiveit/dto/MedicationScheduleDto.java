package com.fiveit.dto;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalTime;

@Data
public class MedicationScheduleDto {
    private String userId;
    private Long mediIdx;
    private LocalDate date;
    private LocalTime time;
    private String taken; // "Y" or "N"
}