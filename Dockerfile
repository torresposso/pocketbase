FROM alpine:latest

ARG PB_VERSION=0.35.0

RUN apk add --no-cache \
    unzip \
    ca-certificates \
    curl

RUN adduser -s /bin/sh -D -h /pb pocketbase

ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip

RUN unzip /tmp/pb.zip -d /pb/ && \
    rm /tmp/pb.zip && \
    chown -R pocketbase:pocketbase /pb

USER pocketbase

EXPOSE 8090

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://0.0.0.0:8090/api/health || exit 1

CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8090"]
