# MLflow Tracking Server — Render + Supabase + Cloudflare R2

Tracking server MLflow auto-hébergé sur Render.  
Backend store : Supabase (PostgreSQL).  
Artifact store : Cloudflare R2 (API S3-compatible).

## Stack

| Composant | Technologie | Rôle |
|-----------|-------------|------|
| Compute | Render Web Service (Docker) | Hébergement du serveur MLflow |
| Backend store | Supabase PostgreSQL | Runs, métriques, paramètres, tags |
| Artifact store | Cloudflare R2 | Modèles, figures, fichiers |
| Auth | MLflow Basic Auth | Protection de l'UI et de l'API |

## Déploiement

```bash
git add .
git commit -m "feat: MLflow tracking server on Render"
git push origin main
```

### 4. Vérifier le déploiement
```bash
# Health check
curl https://mlflow-tracking-server.onrender.com/health

# Lister les experiments via l'API REST
curl -u admin:password \
  https://mlflow-tracking-server.onrender.com/api/2.0/mlflow/experiments/list
```

## Utilisation depuis Python
```python
import mlflow
import os

# Configuration du client
mlflow.set_tracking_uri("https://mlflow-tracking-server.onrender.com")
os.environ["MLFLOW_TRACKING_USERNAME"] = "admin"
os.environ["MLFLOW_TRACKING_PASSWORD"] = "your_password"

# Python Utilisation 
with mlflow.start_run(experiment_id="1"):
    mlflow.log_param("learning_rate", 0.01)
    mlflow.log_metric("rmse", 0.42)
    mlflow.sklearn.log_model(model, "model")
```

## Développement local
```bash
# Build de l'image
docker build -t mlflow-server .

# Lancement avec le .env local
docker run --env-file .env -p 8080:8080 mlflow-server

# Accéder à l'UI
open http://localhost:8080
```