# === Stage 1: Build ===
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

# Kopiér kun pom.xml først — bevarer build cache for dependencies
COPY pom.xml .
RUN mvn dependency:resolve

# Først nu kopieres kode (ændres ofte)
COPY src ./src
RUN mvn package

# === Stage 2: Runtime (minimalt image) ===
FROM eclipse-temurin:21-jre AS runtime
WORKDIR /app

# Kopiér kun jar fra build-stagen
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
