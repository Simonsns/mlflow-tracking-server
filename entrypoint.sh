#!/bin/sh

cat <<EOF > /app/basic_auth.ini
[mlflow]
default_permission = READ
database_uri = ${MLFLOW_AUTH_DATABASE_URI}
admin_username = ${MLFLOW_ADMIN_USERNAME}
admin_password = ${MLFLOW_ADMIN_PASSWORD}
EOF

export MLFLOW_AUTH_CONFIG_PATH=/app/basic_auth.ini
export MLFLOW_FLASK_SERVER_SECRET_KEY=${MLFLOW_FLASK_SERVER_SECRET_KEY}

exec /opt/venv/bin/mlflow server \
    --host 0.0.0.0 \
    --port ${PORT:-8080} \
    --backend-store-uri ${DATABASE_URL} \
    --default-artifact-root ${MLFLOW_S3_BUCKET} \
    --serve-artifacts \
    --app-name basic-auth \
    --gunicorn-opts "--workers 1 --worker-class gthread --threads 1 --timeout 120"