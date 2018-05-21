#!/bin/bash
./start.sh
cd demo
./gradlew sonarqube  -Dorg.gradle.jvmargs=-Xmx2048m -Dsonar.host.url=http://localhost:9000   