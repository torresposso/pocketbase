FROM alpine:latest

ARG PB_VERSION=0.35.1

RUN apk add --no-cache \
    unzip \
    ca-certificates

# download and unzip PocketBase
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

# Create a data directory to ensure it exists and we can mount a volume to it
RUN mkdir -p /pb/pb_data

EXPOSE 443

# start PocketBase
CMD ["/pb/pocketbase", "serve", "--https=0.0.0.0:443", "--dir=/pb/pb_data"]
