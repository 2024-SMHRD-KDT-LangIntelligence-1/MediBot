package com.fiveit.dto;

import lombok.Data;

@Data
public class UpdateTimeRequest {
    private String userId;
    private String mediName;
    private String oldTime;
    private String newTime;
}