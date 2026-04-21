package org.rostyslav.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v2")
class RestApiControllerV2 {

  @Value("classpath:data.json")
  private Resource data;

  @GetMapping("/data")
  public String data() {
    return """
        {"dataType":"private"}
        """;
  }

}