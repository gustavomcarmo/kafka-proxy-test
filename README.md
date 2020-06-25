# kafka-proxy-test

[kafka-proxy](https://github.com/grepplabs/kafka-proxy) test project.

## Setup

`docker-compose up -d`

## Test

`curl -Ls https://mirrors.up.pt/pub/apache/kafka/2.5.0/kafka_2.12-2.5.0.tgz | tar xz`

### No auth test

Comment in [docker-compose.yml](docker-compose.yml):

```yml
      # - --auth-local-enable
      # - --auth-local-command=/auth-ldap
      # - --auth-local-param=--url=ldap://openldap:389
      # - --auth-local-param=--user-dn=ou=people,dc=example,dc=org
      # - --auth-local-param=--user-attr=uid
```

To list the topics:

`kafka_2.12-2.5.0/bin/kafka-topics.sh --list --bootstrap-server localhost:32400,localhost:32401,localhost:32402`

To create the test topic:

`kafka_2.12-2.5.0/bin/kafka-topics.sh --create --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --replication-factor 3 --partitions 1 --topic test`

To produce a single message:

`echo "Hello, World!" | kafka_2.12-2.5.0/bin/kafka-console-producer.sh --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --topic test`

To consume the message:

`kafka_2.12-2.5.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --topic test --from-beginning --max-messages 1`

### LDAP auth test

Uncomment in [docker-compose.yml](docker-compose.yml):

```yml
      - --auth-local-enable
      - --auth-local-command=/auth-ldap
      - --auth-local-param=--url=ldap://openldap:389
      - --auth-local-param=--user-dn=ou=people,dc=example,dc=org
      - --auth-local-param=--user-attr=uid
```

Set the `java.security.auth.login.config` property:

`export KAFKA_OPTS="-Djava.security.auth.login.config=$(pwd)/jaas.conf"`

To produce a single message:

`echo "Hello, World!" | kafka_2.12-2.5.0/bin/kafka-console-producer.sh --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --producer.config client.properties --topic test`

Current error in Kafka client:

```txt
>[2020-06-23 15:19:00,697] WARN [Producer clientId=console-producer] Connection to node -1 (localhost/127.0.0.1:32400) terminated during authentication. This may happen due to any of the following reasons: (1) Authentication failed due to invalid credentials with brokers older than 1.0.0, (2) Firewall blocking Kafka TLS traffic (eg it may only allow HTTPS traffic), (3) Transient network issue. (org.apache.kafka.clients.NetworkClient)
```

Current error in kafka-proxy:

```txt
time="2020-06-23T14:19:00Z" level=info msg="New connection for kafka-0:9092"
time="2020-06-23T14:19:00Z" level=info msg="Reading data from local connection on 172.22.0.6:32400 from 172.22.0.1:48498 (kafka-0:9092) had error: SaslAuthenticate version 0 or 1 is expected, apiVersion 2"
```

#### LDAP auth test using Kafka client 2.3.0 (no errors)

`curl -Ls https://mirrors.up.pt/pub/apache/kafka/2.3.0/kafka_2.12-2.3.0.tgz | tar xz`

To list the topics:

`kafka_2.12-2.3.0/bin/kafka-topics.sh --list --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --command-config client.properties`

To create the test topic:

`kafka_2.12-2.3.0/bin/kafka-topics.sh --create --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --replication-factor 3 --partitions 1 --topic test --command-config client.properties`

To produce a single message:

`echo "Hello, World!" | kafka_2.12-2.3.0/bin/kafka-console-producer.sh --broker-list localhost:32400,localhost:32401,localhost:32402 --topic test --producer.config client.properties`

To consume the message:

`kafka_2.12-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --topic test --from-beginning --max-messages 1 --consumer.config client.properties`

##### LDAP auth test using Kafka client 2.3.0 against VM

`vagrant up`

To list the topics:

`kafka_2.12-2.3.0/bin/kafka-topics.sh --list --bootstrap-server kafka.example.org:32400,kafka.example.org:32401,kafka.example.org:32402 --command-config client.properties`

To create the test topic:

`kafka_2.12-2.3.0/bin/kafka-topics.sh --create --bootstrap-server kafka.example.org:32400,kafka.example.org:32401,kafka.example.org:32402 --replication-factor 3 --partitions 1 --topic test --command-config client.properties`

To produce a single message:

`echo "Hello, World!" | kafka_2.12-2.3.0/bin/kafka-console-producer.sh --broker-list kafka.example.org:32400,kafka.example.org:32401,kafka.example.org:32402 --topic test --producer.config client.properties`

To consume the message:

`kafka_2.12-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server kafka.example.org:32400,kafka.example.org:32401,kafka.example.org:32402 --topic test --from-beginning --max-messages 1 --consumer.config client.properties`
