# ---- Build stage: compile WAR with Maven ----
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q package -DskipTests

# ---- Runtime stage: Tomcat 10.1 (Jakarta EE 10) ----
FROM tomcat:10.1-jdk21-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
# Deploy as ROOT so the app is served at "/"
COPY --from=build /app/target/baitap_so5.war /usr/local/tomcat/webapps/ROOT.war

# Render injects PORT; default to 8080 for local runs
ENV PORT=8080
EXPOSE 8080
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"$PORT\\\"/\" conf/server.xml && exec catalina.sh run"]
