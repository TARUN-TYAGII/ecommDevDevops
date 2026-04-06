FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /usr/src/app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /usr/app
COPY --from=builder /usr/src/app/target/user-service-0.0.1-SNAPSHOT.jar user-service.jar
EXPOSE 8081
CMD ["java", "-jar", "user-service.jar"]