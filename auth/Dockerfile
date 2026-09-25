FROM ghcr.io/gleam-lang/gleam:v1.14.0-erlang-alpine AS builder

WORKDIR /build
COPY . .
RUN gleam export erlang-shipment

FROM erlang:alpine
WORKDIR /app
COPY --from=builder /build/build/erlang-shipment /app

ENTRYPOINT ["/app/entrypoint.sh", "run"]
