// package com.fiveit.Service;
// import org.springframework.http.*;
// import org.springframework.stereotype.Service;
// import org.springframework.web.client.RestTemplate;

// @Service
// public class XGBoostService {
// private final String FASTAPI_URL = "http://112.217.124.195:30002";
// private final RestTemplate restTemplate = new RestTemplate();

// public String updateModel(String userId) {
// String url = FASTAPI_URL + "/update_model";
// JSONObject json = new JSONObject();
// json.put("user_id", userId);

// HttpHeaders headers = new HttpHeaders();
// headers.setContentType(MediaType.APPLICATION_JSON);

// HttpEntity<String> request = new HttpEntity<>(json.toString(), headers);
// return restTemplate.postForObject(url, request, String.class);
// }

// public String predictNext(String userId) {
// String url = FASTAPI_URL + "/predict_next_time";
// JSONObject json = new JSONObject();
// json.put("user_id", userId);

// HttpHeaders headers = new HttpHeaders();
// headers.setContentType(MediaType.APPLICATION_JSON);

// HttpEntity<String> request = new HttpEntity<>(json.toString(), headers);
// return restTemplate.postForObject(url, request, String.class);
// }
// }