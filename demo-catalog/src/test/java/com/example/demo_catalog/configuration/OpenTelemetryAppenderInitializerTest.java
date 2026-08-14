package com.example.demo_catalog.configuration;

import static org.assertj.core.api.Assertions.assertThatCode;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.spi.LoggingEvent;
import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.instrumentation.logback.appender.v1_0.OpenTelemetryAppender;
import org.junit.jupiter.api.Test;
import org.slf4j.LoggerFactory;

class OpenTelemetryAppenderInitializerTest {

  @Test
  void installsOpenTelemetryIntoLogbackAppender() {
    OpenTelemetryAppenderInitializer initializer =
        new OpenTelemetryAppenderInitializer(OpenTelemetry.noop());
    LoggerContext context = (LoggerContext) LoggerFactory.getILoggerFactory();
    OpenTelemetryAppender appender = new OpenTelemetryAppender();
    appender.setContext(context);
    appender.start();
    LoggingEvent event = new LoggingEvent(
        getClass().getName(),
        context.getLogger(getClass()),
        Level.INFO,
        "OpenTelemetry compatibility check",
        null,
        null);

    assertThatCode(() -> {
      initializer.afterPropertiesSet();
      appender.doAppend(event);
    }).doesNotThrowAnyException();

    appender.stop();
  }

}
