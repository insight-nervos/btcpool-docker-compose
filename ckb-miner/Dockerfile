FROM golang:1.15-buster AS builder

# GO ENV VARS
ENV GO111MODULE=on \
    CGO_ENABLED=1 \
    GOOS=linux \
    GOARCH=amd64

# GO BUILD PREP
WORKDIR /build

RUN git clone https://github.com/leifjacky/ckb-gominer-demo /build
RUN go mod init build && go mod tidy

# DO GO BUILD
RUN go build -o main .
WORKDIR /dist
RUN cp /build/main .

# TODO: Change to scratch
FROM ubuntu
COPY --from=builder /build/main /
CMD ["/main"]
