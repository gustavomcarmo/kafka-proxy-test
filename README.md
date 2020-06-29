# kafka-proxy-test

[kafka-proxy](https://github.com/grepplabs/kafka-proxy) test project.

## Requirements

For setting up the local Kafka environment (localhost):

- [Docker](https://www.docker.com)
- [Docker Compose](https://docs.docker.com/compose)

For testing:

- [JDK 1.8](https://openjdk.java.net)
- Java client embedded in [Kafka](https://kafka.apache.org)

For bootstraping a local Kafka VM (kafka.example.org):

- [Virtual Box](https://www.virtualbox.org)
- [Vagrant](https://www.vagrantup.com)
- [Ansible](https://www.ansible.com)

## Tests

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

Then:

`docker-compose up -d`

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

Then:

`docker-compose up -d`

Set the `KAFKA_OPTS` environment variable:

`export KAFKA_OPTS="-Djava.security.auth.login.config=$(pwd)/jaas.conf"`

To list the topics:

`kafka_2.12-2.5.0/bin/kafka-topics.sh --list --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --command-config client-sasl.properties`

To create the test topic:

`kafka_2.12-2.5.0/bin/kafka-topics.sh --create --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --replication-factor 3 --partitions 1 --topic test --command-config client-sasl.properties`

To produce a single message:

`echo "Hello, World!" | kafka_2.12-2.5.0/bin/kafka-console-producer.sh --broker-list localhost:32400,localhost:32401,localhost:32402 --topic test --producer.config client-sasl.properties`

To consume the message:

`kafka_2.12-2.5.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:32400,localhost:32401,localhost:32402 --topic test --from-beginning --max-messages 1 --consumer.config client-sasl.properties`

### LDAP auth/TLS termination test

`vagrant up`

Set the `KAFKA_OPTS` environment variable:

`export KAFKA_OPTS="-Djava.security.auth.login.config=$(pwd)/jaas.conf"`

To list the topics:

`kafka_2.12-2.5.0/bin/kafka-topics.sh --list --bootstrap-server kafka.example.org:32400,kafka.example.org:32401,kafka.example.org:32402 --command-config client-sasl-ssl.properties`

To create the test topic:

`kafka_2.12-2.5.0/bin/kafka-topics.sh --create --bootstrap-server kafka.example.org:32400,kafka.example.org:32401,kafka.example.org:32402 --replication-factor 3 --partitions 1 --topic test --command-config client-sasl-ssl.properties`

To produce a single message:

`echo "Hello, World!" | kafka_2.12-2.5.0/bin/kafka-console-producer.sh --broker-list kafka.example.org:32400,kafka.example.org:32401,kafka.example.org:32402 --topic test --producer.config client-sasl-ssl.properties`

To consume the message:

`kafka_2.12-2.5.0/bin/kafka-console-consumer.sh --bootstrap-server kafka.example.org:32400,kafka.example.org:32401,kafka.example.org:32402 --topic test --from-beginning --max-messages 1 --consumer.config client-sasl-ssl.properties`

:information_source: You can use `192.168.33.10` instead of `kafka.example.org`.
