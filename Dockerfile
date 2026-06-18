#Stage 1: Build
FROM maven:3.8.4-openjdk-17-slim AS build

WORKDIR /app


COPY pom.xml .
RUN mvn dependency:go-offline -B

#
COPY src ./src
RUN mvn clean package -DskipTests

#Stage 2: Run
FROM eclipse-temurin:17-jdk

WORKDIR  /app

RUN apt-get update && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*

COPY --from=build  /app/target/*.jar app.jar

RUN useradd -m appuser && chown -R appuser:appuser /app 

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"] 