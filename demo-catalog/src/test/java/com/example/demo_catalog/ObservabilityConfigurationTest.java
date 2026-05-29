package com.example.demo_catalog;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

import static org.assertj.core.api.Assertions.assertThat;

class ObservabilityConfigurationTest {

  @Test
  void k8sProfileExportsMetricsAndTracesToOpenTelemetryCollector() throws IOException {
    String applicationK8s = readResource("/application-k8s.yaml");

    assertThat(applicationK8s)
        .contains("management:")
        .contains("management.otlp.metrics.export.url")
        .contains("management.otlp.metrics.export.enabled: true")
        .contains("http://opentelemetry-collector.monitoring.svc.cluster.local:4318/v1/metrics")
        .contains("management.tracing.export.otlp.enabled: true")
        .contains("management.opentelemetry.tracing.export.otlp.endpoint")
        .contains("http://opentelemetry-collector.monitoring.svc.cluster.local:4318/v1/traces")
        .contains("probability: 1.0")
        .contains("service.name: catalog");
  }

  @Test
  void defaultProfileDoesNotExportOtlpSignalsWithoutLocalCollector() throws IOException {
    String application = readResource("/application.yaml");

    assertThat(application)
        .contains("enabled: false")
        .contains("otlp:")
        .contains("metrics:")
        .contains("tracing:");
  }

  @Test
  void k8sDeploymentAnnotatesCatalogLogsForOpenTelemetryCollector() throws IOException {
    String deployment = readFile("k8s/demo-catalog/deployment.yaml");

    assertThat(deployment)
        .contains("resource.opentelemetry.io/service.name: catalog")
        .contains("resource.opentelemetry.io/service.namespace: demo-catalog");
  }

  private String readResource(String resourcePath) throws IOException {
    try (var inputStream = getClass().getResourceAsStream(resourcePath)) {
      assertThat(inputStream).as(resourcePath).isNotNull();
      return new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
    }
  }

  private String readFile(String path) throws IOException {
    return java.nio.file.Files.readString(java.nio.file.Path.of("..", path), StandardCharsets.UTF_8);
  }
}
