package com.fiveit.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "tb_medi_info")
public class MediInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id; // 기본키 (자동 증가)

    @Column(name = "user_id", nullable = false, unique = true)
    private String userId; // ✅ 사용자 참조

    @Column(name = "medi_name", nullable = false)
    private String mediName; // 약 이름

    @Column(name = "medi_desc", columnDefinition = "TEXT")
    private String mediDesc; // 약 설명

    @Column(name = "medi_repo", columnDefinition = "TEXT")
    private String mediRepo; // 약 주의사항

    @Column(name = "medi_inter", columnDefinition = "TEXT")
    private String mediInter; // 약 주의사항 (2)

    @Column(name = "medi_warn", columnDefinition = "TEXT")
    private String mediWarn; // 약 부작용

    @Column(name = "medi_despo", columnDefinition = "TEXT")
    private String mediDespo; // 약 보관법

    @Column(name = "category")
    private String category; // 약 분류
}