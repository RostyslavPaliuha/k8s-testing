package com.example.demo_catalog;

import org.junit.jupiter.api.Test;
import org.springframework.boot.env.YamlPropertySourceLoader;
import org.springframework.core.env.MapPropertySource;
import org.springframework.core.env.StandardEnvironment;
import org.springframework.core.io.ClassPathResource;

import java.io.IOException;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class K8sSecurityPropertiesTest {

  private static final String ISSUER_URI_PROPERTY =
      "spring.security.oauth2.resourceserver.jwt.issuer-uri";

  @Test
  void usesPublicDevAuthorizationServerAsDefaultIssuer() throws IOException {
    StandardEnvironment environment = loadK8sEnvironment();

    assertThat(environment.getRequiredProperty(ISSUER_URI_PROPERTY))
        .isEqualTo("https://auth.dev.k8s.plustvs.net/authorization");
  }

  @Test
  void allowsIssuerToBeOverriddenForOtherEnvironments() throws IOException {
    StandardEnvironment environment = loadK8sEnvironment();
    environment.getPropertySources().addFirst(new MapPropertySource(
        "test-override",
        Map.of("AUTHORIZATION_SERVER_ISSUER_URI", "https://auth.example.test/authorization")));

    assertThat(environment.getRequiredProperty(ISSUER_URI_PROPERTY))
        .isEqualTo("https://auth.example.test/authorization");
  }

  private StandardEnvironment loadK8sEnvironment() throws IOException {
    StandardEnvironment environment = new StandardEnvironment();
    var propertySources = new YamlPropertySourceLoader().load(
        "application-k8s.yaml",
        new ClassPathResource("application-k8s.yaml"));
    propertySources.forEach(environment.getPropertySources()::addLast);
    return environment;
  }
}
