#!/bin/bash
docker-compose -f docker-compose.yml up -d
cd demo
./gradlew sonarqube  -Dorg.gradle.jvmargs=-Xmx2048m -Dsonar.host.url=http://localhost:9000   