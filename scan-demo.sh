#!/usr/bin/env bash

echo "=== Vulnerability Scanning Demo ==="
echo

# Build both versions
echo "Building applications..."
docker compose build

echo
echo "=== Scanning DockerHub Version ==="
grype spring-uber-app-dhb:latest

echo
echo "=== Scanning Bitnami Secure Images Version ==="
grype spring-uber-app-bsi:latest
