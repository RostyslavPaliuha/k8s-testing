# Stage 1: Build the application
FROM eclipse-temurin:25-jdk-jammy AS builder

WORKDIR /workspace

# Copy Maven wrapper and pom.xml first for better layer caching
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

# Copy source code and build the application
COPY src/ ./src/
RUN ./mvnw clean package -DskipTests -B

# Stage 2: Create the runtime image
FROM eclipse-temurin:25-jre-jammy AS runtime

RUN apt-get update \
    && apt-get install --no-install-recommends --yes curl \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Kubernetes
ENV SPRING_PROFILES_ACTIVE=default
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0 -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=9875 -Dcom.sun.management.jmxremote.rmi.port=9875 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.host=0.0.0.0 -Djava.rmi.server.hostname=127.0.0.1"

WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /workspace/target/*.jar app.jar
# Expose the Spring Boot and JMX/RMI ports
EXPOSE 8083 9875

# Health check for Kubernetes readiness/liveness probes
HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8083/actuator/health || exit 1

# Run the application with JVM options optimized for containers
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
