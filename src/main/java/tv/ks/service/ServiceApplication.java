package tv.ks.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.core.io.Resource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@SpringBootApplication
public class ServiceApplication {

  public static void main(String[] args) {
    SpringApplication.run(ServiceApplication.class, args);
  }

}

@RestController
@RequestMapping("/v1")
class RestApiController {

  @Value("classpath:data.json")
  private Resource data;

  @GetMapping("/data")
  public String data() throws IOException {
    return data.getContentAsString(StandardCharsets.UTF_8);
  }

}
