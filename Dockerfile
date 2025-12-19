# Stage 1: Downloader
FROM alpine:latest AS downloader

# Argument to easily upgrade PocketBase versions later
ARG PB_VERSION=0.34.2

WORKDIR /app

# Install unzip and curl to download the file
RUN apk add --no-cache unzip curl

# Download and unzip PocketBase
# Note: We use "linux_amd64" which works for Railway standard runners
RUN curl -L https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip \
  -o pb.zip \
  && unzip pb.zip \
  && rm pb.zip

# Stage 2: Final Image
FROM alpine:latest

# Install CA certificates (for making HTTPS requests) and Tini
RUN apk add --no-cache ca-certificates tini

WORKDIR /app

# Copy the executable from the downloader stage
COPY --from=downloader /app/pocketbase /app/pocketbase

# Create the data directory
RUN mkdir -p /pb_data

# Expose the default port
EXPOSE 8090

# Define the volume for persistence
VOLUME /pb_data

# Use Tini as the entrypoint for safe signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Default command to run PocketBase
# "0.0.0.0" is required to be accessible outside the container (e.g. by Railway)
CMD ["/app/pocketbase", "serve", "--http=0.0.0.0:8090", "--dir=/pb_data"]
