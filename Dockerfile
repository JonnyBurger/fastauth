FROM alpine:3.13 AS base
RUN apk update && apk add --update make gcc musl-dev go
WORKDIR /app
COPY go.* Makefile cache ./
#here we build cache.go, as this takes ages to compile and does not change
RUN make dep && make build && rm fastauth cache.go

FROM base as builder
COPY *.go *.sql login.html banner.txt ./
RUN make build test

FROM gcr.io/distroless/static
WORKDIR /home/nonroot
COPY --from=builder /app/login.html /app/banner.txt /app/fastauth /app/rmdb.sql /app/init.sql ./
USER nonroot
ENTRYPOINT ["/home/nonroot/fastauth"]
