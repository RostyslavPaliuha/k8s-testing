package org.rostyslav.service;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.core.io.Resource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
@SpringBootApplication
@EnableConfigurationProperties({GoogleClientProperties.class})
public class ServiceApplication {

  public static void main(String[] args) {
    SpringApplication.run(ServiceApplication.class, args);
  }

}

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