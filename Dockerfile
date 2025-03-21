# build stage
FROM golang:1.16-alpine AS build-env
RUN apk add --no-cache \
    git \
    make \
    gcc \
    libc-dev \
    tzdata \
    zip \
    ca-certificates

ENV GO111MODULE=on \
    CGO_ENABLED=0
    
WORKDIR /src

COPY go.mod .
COPY go.sum .
RUN go mod download

# add source
ADD . .

RUN make build

# final stage
FROM scratch
COPY --from=build-env /src/bin/dex /app/dex

# the timezone data:
COPY --from=build-env /usr/share/zoneinfo /usr/share/zoneinfo
# the tls certificates:
COPY --from=build-env /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["/app/dex"]