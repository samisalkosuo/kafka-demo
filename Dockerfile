FROM apache/kafka:latest

#kafka-ui
WORKDIR /tmp

ENV ENABLE_KAFKA_UI=true
ENV AUTH_TYPE="LOGIN_FORM"
ENV SPRING_SECURITY_USER_NAME=admin
ENV SPRING_SECURITY_USER_PASSWORD=passw0rd

ENV KAFKA_UI_JAR=kafka-ui-api-v0.7.2.jar
RUN wget https://github.com/provectus/kafka-ui/releases/download/v0.7.2/${KAFKA_UI_JAR}
COPY kafka-ui.yaml /tmp/kafka-ui.yaml

EXPOSE 8080

#kafka
ENV KAFKA_EXTERNAL_PORT=9092

WORKDIR /

EXPOSE 9092

COPY start-kafka.sh /etc/kafka/docker/

USER appuser
#VOLUME ["/etc/kafka/secrets", "/var/lib/kafka/data", "/mnt/shared/config"]

CMD ["bash","/etc/kafka/docker/start-kafka.sh"]
