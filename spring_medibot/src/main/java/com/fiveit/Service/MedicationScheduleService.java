// package com.fiveit.Service;

// import com.fiveit.dto.MedicationScheduleDto;
// import com.fiveit.model.MedicationSchedule;
// import com.fiveit.repository.MedicationScheduleRepository;

// import org.apache.el.stream.Optional;
// import org.springframework.stereotype.Service;

// import java.time.LocalDate;
// import java.time.LocalTime;
// import java.util.List;

// @Service
// public class MedicationScheduleService {

// private final MedicationScheduleRepository scheduleRepository;

// public MedicationScheduleService(MedicationScheduleRepository
// scheduleRepository) {
// this.scheduleRepository = scheduleRepository;
// }

// // 복약 일정 등록
// public MedicationSchedule createSchedule(MedicationScheduleDto dto) {
// MedicationSchedule schedule = MedicationSchedule.builder()
// .userId(dto.getUserId())
// .mediIdx(dto.getMediIdx())
// .tmDate(dto.getDate())
// .tmTime(dto.getTime())
// .tmDone(dto.getTaken()) // 기본값 'N' (미복용)
// .build();
// return scheduleRepository.save(schedule);
// }

// // 특정 날짜의 복약 일정 조회
// public List<MedicationSchedule> getSchedulesByUserAndDate(String userId,
// LocalDate date) {
// return scheduleRepository.findByUserIdAndTmDate(userId, date);
// }

// // 복약 일정 수정 (날짜, 시간, 복약 여부 업데이트)
// // public MedicationSchedule updateSchedule(Long tmIdx,
// // MedicationScheduleUpdateDto dto) {
// // Optional<MedicationSchedule> optionalSchedule =
// // scheduleRepository.findById(tmIdx);
// // if (optionalSchedule.isEmpty()) {
// // throw new IllegalArgumentException("해당 복약 일정이 존재하지 않습니다.");
// // }

// // MedicationSchedule schedule = optionalSchedule.get();
// // schedule.setTmDate(dto.getDate());
// // schedule.setTmTime(dto.getTime());
// // schedule.setTmDone(dto.getTaken());

// // // 복약 여부가 'Y'인 경우, 실제 복용 시간을 기록
// // if ("Y".equals(dto.getTaken())) {
// // schedule.setRealTmAt(LocalTime.now());
// // } else {
// // schedule.setRealTmAt(null);
// // }

// // return scheduleRepository.save(schedule);
// // }

// // 복약 일정 삭제
// public void deleteSchedule(Long tmIdx) {
// if (!scheduleRepository.existsById(tmIdx)) {
// throw new IllegalArgumentException("삭제할 복약 일정이 존재하지 않습니다.");
// }
// scheduleRepository.deleteById(tmIdx);
// }
// }