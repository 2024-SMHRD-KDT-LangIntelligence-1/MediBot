package com.fiveit.medibot.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter

@Configuration // Spring Bean으로 등록
@ConfigurationProperties(prefix = "jwt") // application.properties의 "jwt" 속성 연결
public class JwtProperties {
    private String secret;
    private long expiration;
    private long accessTokenValidity; // Access Token 유효 기간
    private long refreshTokenValidity; // Refresh Token 유효 기간

    public String getSecret() {
        return secret;
    }

    public void setSecret(String secret) {
        this.secret = secret;
    }

    public long getExpiration() {
        return expiration;
    }

    public void setExpiration(long expiration) {
        this.expiration = expiration;
    }
}