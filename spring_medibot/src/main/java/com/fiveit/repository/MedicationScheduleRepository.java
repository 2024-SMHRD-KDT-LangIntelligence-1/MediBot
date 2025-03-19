package com.fiveit.repository;

import com.fiveit.model.MedicationSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface MedicationScheduleRepository extends JpaRepository<MedicationSchedule, Long> {
    List<MedicationSchedule> findByUserIdAndTmDate(String userId, LocalDate date);

    @Query("SELECT m FROM MedicationSchedule m WHERE LOWER(TRIM(m.userId)) = LOWER(TRIM(:userId))")
    List<MedicationSchedule> findByUserId(@Param("userId") String userId);
}
