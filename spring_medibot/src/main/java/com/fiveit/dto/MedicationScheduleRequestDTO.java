package com.fiveit.dto;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalTime;

@Data
public class MedicationScheduleRequestDTO {
    private String userId; // ✅ userId (Flutter에서 일치해야 함)
    private String mediName; // ✅ mediName (Flutter에서 일치해야 함)
    private String tmDate; // ✅ tmDate (Flutter에서 YYYY-MM-DD 형식)
    private String tmTime; // ✅ tmTime (Flutter에서 HH:mm 형식)
    private String tmDone; // ✅ tmDone (Flutter에서 "Y" or "N")
    private LocalTime realTmAt; // ✅ String → LocalTime 변경
}