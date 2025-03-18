package com.fiveit.model;

import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "tb_dl_recommedation")
public class DlRecommendation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "dl_idx")
    private Long id;

    // @ManyToOne
    @Column(name = "user_id", nullable = false, unique = true)
    private String userId; // ✅ 사용자 참조

    private String dlLearning;
    private String userReco;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}