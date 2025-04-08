// package com.fiveit.controller;

// import com.fiveit.Service.XGBoostService;
// import org.springframework.web.bind.annotation.*;
// import org.springframework.http.ResponseEntity;

// @RestController
// @RequestMapping("/api/model")
// public class XGBoostController {
// private final XGBoostService fastApi;

// public XGBoostController(XGBoostService fastApi) {
// this.fastApi = fastApi;
// }

// @PostMapping("/update")
// public ResponseEntity<String> update(@RequestParam String userId) {
// return ResponseEntity.ok(fastApi.updateModel(userId));
// }

// @GetMapping("/predict")
// public ResponseEntity<String> predict(@RequestParam String userId) {
// return ResponseEntity.ok(fastApi.predictNext(userId));
// }
// }