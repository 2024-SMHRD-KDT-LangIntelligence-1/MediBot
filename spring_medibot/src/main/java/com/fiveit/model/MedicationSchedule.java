package com.fiveit.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "tm_schedule")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MedicationSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long tmIdx; // 복약 일정 ID

    private String userId; // 사용자 아이디 (VARCHAR 50)
    private Long mediIdx; // 약 ID (INT UNSIGNED)
    private LocalDate tmDate; // 복약 날짜 (DATE)
    private LocalTime tmTime; // 복약 시간 (TIME)

    @Column(length = 1)
    private String tmDone; // 복약 여부 ('Y' 또는 'N')

    private LocalTime realTmAt; // 실제 복용 시간 (TIMESTAMP, NULL 가능)
}