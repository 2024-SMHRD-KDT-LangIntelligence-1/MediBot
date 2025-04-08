package com.fiveit.model;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum Gender {
    M("남성"),
    F("여성"),
    UNKNOWN("미지정");

    private final String korean;

    Gender(String korean) {
        this.korean = korean;
    }

    @JsonValue
    public String getKorean() {
        return korean;
    }

    @JsonCreator
    public static Gender fromString(String value) {
        for (Gender g : Gender.values()) {
            if (g.korean.equals(value) || g.name().equalsIgnoreCase(value)) {
                return g;
            }
        }
        return UNKNOWN;
    }
}