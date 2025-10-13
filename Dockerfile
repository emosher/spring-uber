# Dockerhub images included here for comparison to BSI images
# FROM eclipse-temurin:17-jdk-jammy as builder
FROM us-east1-docker.pkg.dev/vmw-app-catalog/hosted-registry-e4c6ba6fd76/containers/photon-5/java:21 as builder
WORKDIR /app
COPY . .
RUN ./gradlew bootJar

# FROM eclipse-temurin:17-jre-jammy
FROM us-east1-docker.pkg.dev/vmw-app-catalog/hosted-registry-e4c6ba6fd76/containers/photon-5/java-min:21
EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.jar"]