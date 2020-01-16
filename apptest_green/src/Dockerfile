#FROM java:8
FROM gradle:latest-jdk-8
MAINTAINER sypete

#VOLUME /my-logs/app.log
ARG JAVA_OPTS
ENV JAVA_OPTS=$JAVA_OPTS
#ADD build/libs/gs-spring-boot-docker-0.1.0.jar apptest.jar
#EXPOSE 3000
#ENTRYPOINT exec java $JAVA_OPTS -jar apptest.jar
# For Spring-Boot project, use the entrypoint below to reduce Tomcat startup time.
#ENTRYPOINT exec java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar apptest.jar
