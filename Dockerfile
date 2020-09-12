FROM golang:1.15 as builder
ARG PAT
WORKDIR /build
COPY go.mod .
COPY go.sum .
RUN go env -w GOPRIVATE=github.com/philips-internal/*
ENV PAT ${PAT}
RUN env
RUN git config --global url."https://golang:${PAT}@github.com".insteadOf "https://github.com"

RUN go mod download

# Build
COPY . .
RUN git rev-parse --short HEAD
RUN GIT_COMMIT=$(git rev-parse --short HEAD) && \
    CGO_ENABLED=0 GOOS=linux go build -o app -ldflags "-X main.GitCommit=${GIT_COMMIT}"

FROM alpine:latest 
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
WORKDIR /app
COPY --from=builder /build/app /app
EXPOSE 8080
CMD ["/app/app"]
