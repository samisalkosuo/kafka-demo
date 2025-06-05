FROM apache/kafka:latest

#kafka-ui
WORKDIR /tmp

#set user name and password for UI
ENV SPRING_SECURITY_USER_NAME=admin
ENV SPRING_SECURITY_USER_PASSWORD=passw0rd

#not really meant to be changed
ENV ENABLE_KAFKA_UI=true
ENV AUTH_TYPE="LOGIN_FORM"
ENV UI_JAR=kafka-ui-api-v0.7.2.jar

#download UI jar
RUN wget https://github.com/provectus/kafka-ui/releases/download/v0.7.2/${UI_JAR}

#kafka-ui configuration
COPY kafka-ui.yaml /tmp/kafka-ui.yaml

EXPOSE 8080

#kafka
ENV EXTERNAL_PORT=9092
ENV GENERATE_HEALTHCARE_VISIT_MESSAGES=false

WORKDIR /

EXPOSE 9092

COPY generate-healthcare-visits.sh /tmp/

COPY start-kafka.sh /etc/kafka/docker/

USER appuser
#VOLUME ["/etc/kafka/secrets", "/var/lib/kafka/data", "/mnt/shared/config"]

CMD ["bash","/etc/kafka/docker/start-kafka.sh"]
