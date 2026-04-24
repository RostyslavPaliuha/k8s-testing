# Stage 1: Build the application
FROM eclipse-temurin:25-jdk AS builder

WORKDIR /workspace

# Copy Maven wrapper and pom.xml first for better layer caching
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

# Download dependencies (cached unless pom.xml changes)
RUN ./mvnw dependency:go-offline -B

# Copy source code and build the application
COPY src/ ./src/
RUN ./mvnw clean package -DskipTests -B

# Stage 2: Create the runtime image
FROM eclipse-temurin:25-jre AS runtime

# Set environment variables for Kubernetes
ENV SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-default}
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0"

WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /workspace/target/*.jar app.jar

# Expose the default Spring Boot port
EXPOSE 8080

# Health check for Kubernetes readiness/liveness probes
HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application with JVM options optimized for containers
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
