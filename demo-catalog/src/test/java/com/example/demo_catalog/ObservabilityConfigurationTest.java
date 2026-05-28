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
  void logbackPushesCatalogLogsToLokiWithTraceCorrelation() throws IOException {
    String logback = readResource("/logback-spring.xml");

    assertThat(logback)
        .contains("com.github.loki4j.logback.Loki4jAppender")
        .contains("http://loki-gateway.monitoring.svc.cluster.local/loki/api/v1/push")
        .contains("app = catalog")
        .contains("namespace = demo-catalog-ns")
        .contains("trace_id = %X{traceId:-}")
        .contains("span_id = %X{spanId:-}");
  }

  private String readResource(String resourcePath) throws IOException {
    try (var inputStream = getClass().getResourceAsStream(resourcePath)) {
      assertThat(inputStream).as(resourcePath).isNotNull();
      return new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
    }
  }
}
