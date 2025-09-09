FROM us-east1-docker.pkg.dev/vmw-app-catalog/hosted-registry-e4c6ba6fd76/containers/photon-5/java:21 as builder
WORKDIR /app
COPY . .
RUN ./gradlew bootJar

FROM us-east1-docker.pkg.dev/vmw-app-catalog/hosted-registry-e4c6ba6fd76/containers/photon-5/java-min@sha256:4e9f325d4ae9d283852fb03b4b746b151d1d943583180212d0fd94e42f60efad
EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.jar"]