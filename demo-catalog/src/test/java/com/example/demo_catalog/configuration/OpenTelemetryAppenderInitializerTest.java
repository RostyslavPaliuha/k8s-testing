package com.example.demo_catalog.configuration;

import static org.assertj.core.api.Assertions.assertThatCode;

import io.opentelemetry.api.OpenTelemetry;
import org.junit.jupiter.api.Test;

class OpenTelemetryAppenderInitializerTest {

  @Test
  void installsOpenTelemetryIntoLogbackAppender() {
    OpenTelemetryAppenderInitializer initializer =
        new OpenTelemetryAppenderInitializer(OpenTelemetry.noop());

    assertThatCode(initializer::afterPropertiesSet).doesNotThrowAnyException();
  }

}
