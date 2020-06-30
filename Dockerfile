FROM golang:1.14 as builder
WORKDIR /go/src/github.com/grepplabs/kafka-proxy
RUN git clone https://github.com/grepplabs/kafka-proxy --branch v0.2.4 . \
    && make clean build plugin.auth-ldap

FROM alpine:3.11
RUN apk add --no-cache ca-certificates
COPY --from=builder /go/src/github.com/grepplabs/kafka-proxy/build/kafka-proxy /kafka-proxy
COPY --from=builder /go/src/github.com/grepplabs/kafka-proxy/build/auth-ldap /auth-ldap
ENTRYPOINT ["/kafka-proxy"]
CMD ["--help"]