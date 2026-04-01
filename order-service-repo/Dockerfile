# =============================================================
# order-service/Dockerfile — Multi-stage production build (Go)
# =============================================================

FROM golang:1.22-alpine AS builder
WORKDIR /app

# Cache Go module download
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o order-service ./cmd/server

# Stage 2: Minimal runtime (scratch or distroless)
FROM gcr.io/distroless/static-debian12 AS runtime

COPY --from=builder /app/order-service /order-service

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD ["/order-service", "-health-check"]

USER nonroot:nonroot

ENTRYPOINT ["/order-service"]
