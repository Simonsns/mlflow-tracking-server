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
    mlflow-skinny[auth]==3.10.1 \
    boto3==1.35.0 \
    psycopg2-binary==2.9.10

# ── Runtime stage ───────────────────────────────────────────────────
FROM python:3.12-slim AS runtime

RUN groupadd --gid 1001 mlflow \
    && useradd --uid 1001 --gid mlflow --shell /bin/sh mlflow

WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
COPY entrypoint.sh ./entrypoint.sh

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN chown -R mlflow:mlflow /app && chmod +x /app/entrypoint.sh

# Init config finale 
USER mlflow
ENV PATH="/opt/venv/bin:$PATH"
EXPOSE 8080

CMD ["/bin/sh", "/app/entrypoint.sh"]