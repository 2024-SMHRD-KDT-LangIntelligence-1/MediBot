package com.fiveit.Service;

import com.fiveit.dto.MedicationScheduleRequestDTO;
import com.fiveit.model.MedicationSchedule;
import com.fiveit.repository.MedicationScheduleRepository;

import jakarta.transaction.Transactional;

import org.apache.el.stream.Optional;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Service
public class MedicationScheduleService {

    private final MedicationScheduleRepository medicationScheduleRepository;

    public MedicationScheduleService(MedicationScheduleRepository medicationScheduleRepository) {
        this.medicationScheduleRepository = medicationScheduleRepository;
    }

    // ✅ 약 복용 스케줄 저장
    @Transactional
    public MedicationSchedule saveSchedule(MedicationScheduleRequestDTO dto) {
        MedicationSchedule schedule = new MedicationSchedule();

        // ✅ 문자열 날짜/시간을 LocalDate 및 LocalTime으로 변환 (만약 엔티티가 LocalDate 사용한다면)
        schedule.setTmDate(LocalDate.parse(dto.getTmDate())); // YYYY-MM-DD
        schedule.setTmTime(LocalTime.parse(dto.getTmTime())); // HH:mm

        // ✅ "Y" / "N" 값을 boolean으로 변환
        schedule.setTmDone(dto.getTmDone().equalsIgnoreCase("Y"));

        // ✅ realTmAt가 null이 아닐 때만 변환
        schedule.setRealTmAt(dto.getRealTmAt());

        // ✅ userId & 약 이름 그대로 매핑
        schedule.setUserId(dto.getUserId());
        schedule.setMediName(dto.getMediName());

        return medicationScheduleRepository.save(schedule);
    }

    // ✅ 특정 유저의 스케줄 조회
    public List<MedicationSchedule> getSchedulesByUser(String userId) {
        return medicationScheduleRepository.findAll().stream()
                .filter(schedule -> schedule.getUserId().equals(userId))
                .toList();
    }

}