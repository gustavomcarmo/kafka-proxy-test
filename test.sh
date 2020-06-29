#!/bin/bash

teardown()
{
    echo "Tearing down the local Kafka environment"
    docker-compose down
    docker volume rm kafka-proxy-test_zookeeper_data
    docker volume rm kafka-proxy-test_kafka-0_data
    docker volume rm kafka-proxy-test_kafka-1_data
    docker volume rm kafka-proxy-test_kafka-2_data
}

echo "Setting up the local Kafka environment"
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "Error on setting up the local Kafka environment."
    teardown
    exit 1
fi

echo "Downloading Kafka"
curl -Ls https://mirrors.up.pt/pub/apache/kafka/2.5.0/kafka_2.12-2.5.0.tgz | tar xz
if [ $? -ne 0 ]; then
    echo "Error on downloading Kafka."
    teardown
    exit 1
fi

export KAFKA_OPTS="-Djava.security.auth.login.config=$(pwd)/jaas.conf"

echo "Creating the test topic"
kafka_2.12-2.5.0/bin/kafka-topics.sh --create --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --replication-factor 3 --partitions 1 --topic test --command-config client-sasl.properties
if [ $? -ne 0 ]; then
    echo "Error on creating the test topic."
    teardown
    exit 1
fi

echo "Sending a single 'Hello, World!' message"
echo "Hello, World!" | kafka_2.12-2.5.0/bin/kafka-console-producer.sh --broker-list localhost:32400,localhost:32401,localhost:32402 --topic test --producer.config client-sasl.properties
if [ $? -ne 0 ]; then
    echo "Error on sending a single message."
    teardown
    exit 1
fi

echo "Consuming the sent message"
kafka_2.12-2.5.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --topic test --from-beginning --max-messages 1 --consumer.config client-sasl.properties
if [ $? -ne 0 ]; then
    echo "Error on consuming the sent message."
    teardown
    exit 1
fi

teardown
exit 0