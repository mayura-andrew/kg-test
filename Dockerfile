# ── Stage 1: Build ─────────────────────────────────────────────────────────
FROM golang:1.24.4-bookworm AS builder
WORKDIR /build
COPY go.mod go.sum* ./
RUN go mod download
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /build/migrate .

# ── Stage 2: Runtime ────────────────────────────────────────────────────────
FROM debian:bookworm-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /build/migrate ./migrate
COPY docker/wait-for-neo4j.sh ./wait-for-neo4j.sh
RUN chmod +x ./wait-for-neo4j.sh
ENV NEO4J_URI="bolt://neo4j:7687" \
    NEO4J_USER="neo4j" \
    NEO4J_PASSWORD=""
ENTRYPOINT ["./wait-for-neo4j.sh"]
CMD ["./migrate", "--data", "data/raw", "--verify"]
