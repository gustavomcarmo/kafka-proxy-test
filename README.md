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

Current error:

```
>[2020-06-20 10:45:05,775] WARN [Producer clientId=console-producer] Error connecting to node localhost:32400 (id: -1 rack: null) (org.apache.kafka.clients.NetworkClient)
java.io.IOException: Channel could not be created for socket java.nio.channels.SocketChannel[closed]
        at org.apache.kafka.common.network.Selector.buildAndAttachKafkaChannel(Selector.java:348)
        at org.apache.kafka.common.network.Selector.registerChannel(Selector.java:329)
        at org.apache.kafka.common.network.Selector.connect(Selector.java:256)
        at org.apache.kafka.clients.NetworkClient.initiateConnect(NetworkClient.java:957)
        at org.apache.kafka.clients.NetworkClient.access$600(NetworkClient.java:73)
        at org.apache.kafka.clients.NetworkClient$DefaultMetadataUpdater.maybeUpdate(NetworkClient.java:1128)
        at org.apache.kafka.clients.NetworkClient$DefaultMetadataUpdater.maybeUpdate(NetworkClient.java:1016)
        at org.apache.kafka.clients.NetworkClient.poll(NetworkClient.java:547)
        at org.apache.kafka.clients.producer.internals.Sender.runOnce(Sender.java:324)
        at org.apache.kafka.clients.producer.internals.Sender.run(Sender.java:239)
        at java.lang.Thread.run(Thread.java:748)
Caused by: org.apache.kafka.common.KafkaException: org.apache.kafka.common.errors.SaslAuthenticationException: Failed to configure SaslClientAuthenticator
        at org.apache.kafka.common.network.SaslChannelBuilder.buildChannel(SaslChannelBuilder.java:228)
        at org.apache.kafka.common.network.Selector.buildAndAttachKafkaChannel(Selector.java:338)
        ... 10 more
Caused by: org.apache.kafka.common.errors.SaslAuthenticationException: Failed to configure SaslClientAuthenticator
Caused by: org.apache.kafka.common.KafkaException: Principal could not be determined from Subject, this may be a transient failure due to Kerberos re-login
        at org.apache.kafka.common.security.authenticator.SaslClientAuthenticator.firstPrincipal(SaslClientAuthenticator.java:579)
        at org.apache.kafka.common.security.authenticator.SaslClientAuthenticator.<init>(SaslClientAuthenticator.java:171)
        at org.apache.kafka.common.network.SaslChannelBuilder.buildClientAuthenticator(SaslChannelBuilder.java:274)
        at org.apache.kafka.common.network.SaslChannelBuilder.lambda$buildChannel$1(SaslChannelBuilder.java:216)
        at org.apache.kafka.common.network.KafkaChannel.<init>(KafkaChannel.java:143)
        at org.apache.kafka.common.network.SaslChannelBuilder.buildChannel(SaslChannelBuilder.java:224)
        at org.apache.kafka.common.network.Selector.buildAndAttachKafkaChannel(Selector.java:338)
        at org.apache.kafka.common.network.Selector.registerChannel(Selector.java:329)
        at org.apache.kafka.common.network.Selector.connect(Selector.java:256)
        at org.apache.kafka.clients.NetworkClient.initiateConnect(NetworkClient.java:957)
        at org.apache.kafka.clients.NetworkClient.access$600(NetworkClient.java:73)
        at org.apache.kafka.clients.NetworkClient$DefaultMetadataUpdater.maybeUpdate(NetworkClient.java:1128)
        at org.apache.kafka.clients.NetworkClient$DefaultMetadataUpdater.maybeUpdate(NetworkClient.java:1016)
        at org.apache.kafka.clients.NetworkClient.poll(NetworkClient.java:547)
        at org.apache.kafka.clients.producer.internals.Sender.runOnce(Sender.java:324)
        at org.apache.kafka.clients.producer.internals.Sender.run(Sender.java:239)
        at java.lang.Thread.run(Thread.java:748)
```
