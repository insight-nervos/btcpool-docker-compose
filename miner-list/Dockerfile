FROM golang:1.7.3 AS builder
WORKDIR /go/src/miner-list
COPY main.go .

RUN go get -d -v ./...
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/miner-list/app .
COPY ./config/miners.json /root/config/
CMD ["./app"]
