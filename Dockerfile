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

COPY --chown=pocketbase:pocketbase ./pb_migrations /pb/pb_migrations
COPY --chown=pocketbase:pocketbase ./pb_hooks /pb/pb_hooks
COPY --chown=pocketbase:pocketbase ./pb_public /pb/pb_public

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/api/health || exit 1

CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]
