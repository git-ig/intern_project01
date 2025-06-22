FROM gradle:6.9.4-jdk11 AS build-stage

COPY ./backend /backend

ARG DATABASE
ARG USERNAME
ARG USERPASSWORD

RUN sed -i "s|hibernate.connection.url=.*|hibernate.connection.url=jdbc:postgresql://postgres:5432/${DATABASE}|" /backend/src/main/resources/hibernate.properties && \
    sed -i "s|hibernate.connection.username=.*|hibernate.connection.username=${USERNAME}|" /backend/src/main/resources/hibernate.properties && \
    sed -i "s|hibernate.connection.password=.*|hibernate.connection.password=${USERPASSWORD}|" /backend/src/main/resources/hibernate.properties && \
    cd /backend && gradle build --no-daemon --console=plain

FROM eclipse-temurin:11-jre-alpine AS deploy

RUN apk add --no-cache curl && \
    mkdir -p /opt && \
    curl -sSL https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz -o /tmp/tomcat.tar.gz && \
    tar -xzf /tmp/tomcat.tar.gz -C /opt && \
    mv /opt/apache-tomcat-9.0.85 /opt/tomcat && \
    rm /tmp/tomcat.tar.gz && \
    rm -rf /opt/tomcat/webapps/* /tmp/tomcat.tar.gz

COPY --from=build-stage /backend/build/libs/*.war /opt/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]
