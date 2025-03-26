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
public class DrugInfo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long medi_id;

    private String mediName;
    private String mediDesc;
    private String mediRepo;
    private String mediInter;
    private String mediWarn;
    private String mediDespo;
    private String category;

    @Column(name = "side_effects")
    private String sideEffects;
    @Column(name = "side_effects_clean")
    private String sideEffectsClean;
    @Column(name = "side_effects_from_repo")
    private String sideEffectsFromRepo;
}