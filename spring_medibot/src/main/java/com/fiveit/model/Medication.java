package com.fiveit.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "tb_medication")
public class Medication {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "medi_idx")
    private Long mediIdx;

    // @ManyToOne
    @Column(name = "user_id", nullable = false, unique = true)
    private String userId; // ✅ 사용자 참조

    @Column(name = "medi_type", nullable = false)
    private String mediType;

    @Column(name = "medi_desc")
    private String mediDesc;
}
