FROM rust:1.43 as builder
RUN git clone https://github.com/nervosnetwork/ckb-miner.git /build

RUN apt update && apt install -y ocl-icd-opencl-dev

WORKDIR /build
RUN cargo build --release --features opencl

FROM debian:buster-slim
COPY --from=builder /build/ckb-miner /

CMD ["/ckb-miner"]