package com.fiveit.repository;

import com.fiveit.model.MedicationSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

public interface MedicationScheduleRepository extends JpaRepository<MedicationSchedule, Long> {
    List<MedicationSchedule> findByUserIdAndTmDate(String userId, LocalDate tmdate);

    @Query("SELECT m FROM MedicationSchedule m WHERE LOWER(TRIM(m.userId)) = LOWER(TRIM(:userId))")
    List<MedicationSchedule> findByUserId(@Param("userId") String userId);

    List<MedicationSchedule> findByUserIdAndMediName(String userId, String mediName);

    // List<MedicationSchedule> findByUserIdAndTmDate(String userId, LocalDate
    // tmDate);
    List<MedicationSchedule> findAllByUserIdAndMediNameAndTmDate(String userId, String mediName, LocalDate tmDate); // ✅
                                                                                                                    // 다중
                                                                                                                    // 결과
                                                                                                                    // 허용
                                                                                                                    // LocalDate
                                                                                                                    // 사용

    List<MedicationSchedule> findByUserIdAndMediNameAndTmTime(String userId, String mediName, LocalTime tmTime);

    @Modifying
    @Query("DELETE FROM MedicationSchedule m WHERE m.userId = :userId")
    void deleteAllByUserId(@Param("userId") String userId);

}
