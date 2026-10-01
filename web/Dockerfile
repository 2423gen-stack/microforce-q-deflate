FROM ghcr.io/gleam-lang/gleam:v1.16.0-erlang-alpine

RUN apk add --no-cache \
    gcc \
    g++ \
    make \
    sqlite-dev \
    sqlite \
    curl \
    git

WORKDIR /app

# 依存関係定義とソースのコピー準備
COPY gleam.toml manifest.toml* ./
RUN if [ -f gleam.toml ]; then gleam deps download; fi

COPY . .

RUN make clean && make

EXPOSE 8080

CMD ["gleam", "run"]
