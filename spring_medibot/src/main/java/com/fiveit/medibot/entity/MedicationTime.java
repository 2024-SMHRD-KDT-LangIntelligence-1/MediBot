package com.fiveit.medibot.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "medication_time")
public class MedicationTime {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // 자동 증가 (PK)

    @Column(nullable = false)
    private String period; // 오전 / 오후 선택

    @Column(nullable = false)
    private LocalTime time; // 약 복용 시간
}