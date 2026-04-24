package org.rostyslav.service;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@RestController
@RequestMapping("/api/v1")
class RestApiController {

  @Value("classpath:data.json")
  private Resource data;

  @Autowired
  private GoogleClientProperties properties;

  @PostConstruct
  public void init() throws IOException {
    System.out.println("DATA FROM VAULT" + properties.getClientId() + " " + properties.getClientSecret());
  }

  @GetMapping("/data")
  public String data() throws IOException, InterruptedException {
    return data.getContentAsString(StandardCharsets.UTF_8);
  }

}
