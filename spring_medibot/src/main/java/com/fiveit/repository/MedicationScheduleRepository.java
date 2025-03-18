package com.fiveit.repository;

import com.fiveit.model.MedicationSchedule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface MedicationScheduleRepository extends JpaRepository<MedicationSchedule, Long> {
    List<MedicationSchedule> findByUserIdAndTmDate(String userId, LocalDate date);
}
