#!/bin/bash

#start kafka UI
if [ "$ENABLE_KAFKA_UI" == "true" ]; then
  java -Dspring.config.additional-location=/tmp/kafka-ui.yaml --add-opens java.rmi/javax.rmi.ssl=ALL-UNNAMED -jar /tmp/${UI_JAR} &
fi

if [ "$GENERATE_HEALTHCARE_VISIT_MESSAGES" == "true" ]; then
  bash /tmp/generate-healthcare-visits.sh &
fi


#create server.properties
cat <<EOF > /mnt/shared/config/server.properties
node.id=1
listeners=CONTROLLER://:29093,CLIENT://:9092,BROKER://:19092,UI://:39092
advertised.listeners=CLIENT://${HOSTNAME}:${EXTERNAL_PORT},UI://localhost:39092,BROKER://localhost:19092
process.roles=broker,controller
controller.quorum.voters=1@localhost:29093
inter.broker.listener.name=BROKER
controller.listener.names=CONTROLLER
cluster.id=4Q6g6nSWT-zMDtK--x86sw
offsets.topic.replication.factor=1
group.initial.rebalance.delay.ms=0
transaction.state.log.min.isr=1
transaction.state.log.replication.factor=1
share.coordinator.state.topic.replication.factor=1
sha re.coordinator.state.topic.min.isr=1
log.dirs=/tmp/kraft-combined-logs
log.retention.hours=0
log.retention.minutes=10
log.retention.check.interval.ms=20000
log.roll.hours=1
#100MB = 104857600 bytes
#250MB = 262144000 bytes
log.segment.bytes=104857600
log.retention.bytes=262144000
listener.security.protocol.map=CONTROLLER:PLAINTEXT,BROKER:PLAINTEXT,CLIENT:PLAINTEXT,UI:PLAINTEXT
EOF

#start kafka
exec /etc/kafka/docker/run
