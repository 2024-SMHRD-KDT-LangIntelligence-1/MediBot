package com.fiveit.medibot;

import com.fiveit.medibot.config.JwtProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties(JwtProperties.class)
public class MedibotApplicationTests {
	public static void main(String[] args) {
		SpringApplication.run(MedibotApplication.class, args);
	}
}
