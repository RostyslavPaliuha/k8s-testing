# Stage 1: Build the application
FROM eclipse-temurin:25-jdk AS builder

ARG OTEL_JAVA_AGENT_VERSION=2.28.1

WORKDIR /workspace

# Copy Maven wrapper and pom.xml first for better layer caching
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

# Download dependencies (cached unless pom.xml changes)
RUN ./mvnw dependency:go-offline -B
RUN ./mvnw org.apache.maven.plugins:maven-dependency-plugin:3.8.1:copy \
    -Dartifact=io.opentelemetry.javaagent:opentelemetry-javaagent:${OTEL_JAVA_AGENT_VERSION}:jar \
    -DoutputDirectory=/workspace/otel-agent \
    -Dmdep.stripVersion=true \
    -B

# Copy source code and build the application
COPY src/ ./src/
RUN ./mvnw clean package -DskipTests -B

# Stage 2: Create the runtime image
FROM eclipse-temurin:25-jre AS runtime

# Set environment variables for Kubernetes
ENV SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-default}
ENV JAVA_OPTS="-javaagent:/app/opentelemetry-javaagent.jar -Dotel.experimental.metrics.view-config=/app/histogram-view.yaml -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0"

WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /workspace/target/*.jar app.jar
COPY --from=builder /workspace/otel-agent/opentelemetry-javaagent.jar opentelemetry-javaagent.jar
COPY histogram-view.yaml /app/histogram-view.yaml
# Expose the default Spring Boot port
EXPOSE 8080

# Health check for Kubernetes readiness/liveness probes
HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application with JVM options optimized for containers
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
