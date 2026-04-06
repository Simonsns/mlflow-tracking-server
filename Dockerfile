# ── Build stage ────────────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /app

# Dépendances système minimales pour psycopg2 (driver PostgreSQL)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Installation des packages Python dans un venv isolé
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# mlflow libraries
# boto3 (R2)
# psycopg2 (Supabase)
# pkg_resources (setuptools < 70)
RUN pip install --no-cache-dir \
    "setuptools<70" \
    mlflow==2.13.0 \
    boto3==1.34.0 \
    psycopg2-binary==2.9.9 \
    gunicorn==21.2.0

# ── Runtime stage ───────────────────────────────────────────────────
FROM python:3.12-slim AS runtime

RUN groupadd --gid 1001 mlflow \
    && useradd --uid 1001 --gid mlflow --shell /bin/sh mlflow

COPY --from=builder /opt/venv /opt/venv

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app 
USER mlflow

# Fixed interpreter
ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 8080

CMD ["sh", "-c", \
    "/opt/venv/bin/mlflow server \
        --host 0.0.0.0 \
        --port ${PORT:-8080} \
        --backend-store-uri ${DATABASE_URL} \
        --default-artifact-root ${MLFLOW_S3_BUCKET} \
        --serve-artifacts \
        --gunicorn-opts '--workers 1 --timeout 120 --keep-alive 5'"]