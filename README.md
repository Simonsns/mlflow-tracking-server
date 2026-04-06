# MLflow Tracking Server - Backend Store (PostgreSQL) - Artifact Store (R2 - S3 Compatible)

Standalone MLflow server:

* Self-hosted MLflow Tracking Server on Railway
* Backend store: Supabase (PostgreSQL)
* Artifact store: Cloudflare R2 (S3-compatible API)

## Stack

| Component      | Technology                   | Role                            |
| -------------- | ---------------------------- | ------------------------------- |
| Compute        | Railway Web Service (Docker) | Hosts the MLflow server         |
| Backend store  | Supabase PostgreSQL          | Runs, metrics, parameters, tags |
| Artifact store | Cloudflare R2                | Models, figures, files          |
| Auth           | MLflow Basic Auth            | Secures UI and API              |

## Deployment

```bash
git add .
git commit -m "feat: MLflow tracking server on Railway"
git push origin main
```

### 4. Verify deployment

```bash
# Health check
curl https://mlflow-tracking-server-production.up.railway.app/health

# List experiments via REST API
curl -u admin:password \
  https://mlflow-tracking-server-production.up.railway.app/api/2.0/mlflow/experiments/list
```

## Usage from Python

```python
import mlflow
import os

# Configure client
mlflow.set_tracking_uri("https://mlflow-tracking-server-production.up.railway.app")

# If authentication is required:
os.environ["MLFLOW_ADMIN_USERNAME"] = "admin"
os.environ["MLFLOW_ADMIN_PASSWORD"] = "your_password"

# By default, the server is accessible in read-only mode

# Python usage
with mlflow.start_run(experiment_id="1"):
    mlflow.log_param("learning_rate", 0.01)
    mlflow.log_metric("rmse", 0.42)
    mlflow.sklearn.log_model(model, "model")
```

## Local Development

```bash
# Build the image
docker build -t mlflow-server .

# Run with local .env file
docker run --env-file .env -p 8080:8080 mlflow-server

# Open the UI
open http://localhost:8080
```
