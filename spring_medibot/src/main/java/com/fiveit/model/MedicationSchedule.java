package com.fiveit.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "tb_tm_schedule")
public class MedicationSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "tm_idx")
    private Long tmIdx;

    @Column(name = "tm_date", nullable = false)
    private LocalDate tmDate;

    @Column(name = "tm_time", nullable = false)
    private LocalTime tmTime;

    @Column(name = "tm_done", nullable = false)
    private boolean tmDone; // ✅ 복용 여부 (true / false)

    @Column(name = "real_tm_at")
    private LocalTime realTmAt; // ✅ 실제 복용 시간

    // @ManyToOne
    @Column(name = "user_id", nullable = false, unique = true)
    private String userId; // ✅ 사용자 참조

    @Column(name = "medi_name")
    private String mediName;
}