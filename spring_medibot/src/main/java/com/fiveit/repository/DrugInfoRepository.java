package com.fiveit.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fiveit.model.DrugInfo;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public interface DrugInfoRepository extends JpaRepository<DrugInfo, Long> {
    List<DrugInfo> findByMediNameContainingIgnoreCase(String mediName);

    List<DrugInfo> findByCategoryContainingIgnoreCase(String category);

    @Query("SELECT d FROM DrugInfo d WHERE " +
            "LOWER(d.mediName) LIKE %:kw1% AND LOWER(d.mediName) LIKE %:kw2%")
    List<DrugInfo> searchByTwoKeywords(@Param("kw1") String kw1, @Param("kw2") String kw2);

    @Query("SELECT d FROM DrugInfo d WHERE " +
            "LOWER(d.category) LIKE %:kw1% AND LOWER(d.category) LIKE %:kw2%")
    List<DrugInfo> searchCategoryByTwoKeywords(@Param("kw1") String kw1, @Param("kw2") String kw2);

    List<DrugInfo> findByMediNameContainingIgnoreCaseOrCategoryContainingIgnoreCase(String name, String category);
}