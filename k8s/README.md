# Kubernetes Deployment for Service

Simple Kubernetes deployment with autoscaling support.

## Quick Start

### Deploy

```bash
./k8s/apply.sh
```

### Access

**Option 1: Port-forward (Docker Desktop Mac/Linux/Windows)**
```bash
# Terminal 1
./k8s/port-forward.sh

# Terminal 2
curl localhost:30081/api/v1/data
```

**Option 2: NodePort (Linux with direct network access)**
```bash
curl localhost:30081/api/v1/data
```

### Cleanup

```bash
./k8s/cleanup.sh
```

### Build & Deploy

```bash
# Build and deploy with 'latest' tag
./k8s/build-and-deploy.sh

# Build and deploy with specific version
./k8s/build-and-deploy.sh 0.0.2

# Manual build and deploy
docker build -t service:0.0.2 .
kubectl set image deployment/service-deployment -n service-ns service=service:0.0.2
kubectl rollout status deployment -n service-ns service-deployment
```

## Files

| File | Description |
|------|-------------|
| `namespace.yaml` | Creates `service-ns` namespace |
| `configmap.yaml` | Environment configuration |
| `deployment.yaml` | Service deployment (1 replica) |
| `service.yaml` | NodePort service (30081) |
| `hpa.yaml` | HorizontalPodAutoscaler (1-10 replicas) |
| `apply.sh` | Deploy everything |
| `cleanup.sh` | Remove everything |
| `port-forward.sh` | Port-forward for local access |
| `build-and-deploy.sh` | Build and deploy new image |
| `load-test.sh` | Load testing script |

## Autoscaling

### Automatic Scaling

HPA scales based on:
- **CPU**: Scale when average > 70%
- **Memory**: Scale when average > 80%
- **Min replicas**: 1
- **Max replicas**: 10

### Manual Scaling

```bash
# Scale to 5 replicas
kubectl scale deployment -n service-ns service-deployment --replicas=5

# Scale to 1 replica
kubectl scale deployment -n service-ns service-deployment --replicas=1

# Scale to 0 (downscale completely)
kubectl scale deployment -n service-ns service-deployment --replicas=0
```

### Check HPA Status

```bash
kubectl get hpa -n service-ns
kubectl get hpa -n service-ns --watch
```

## Architecture

```
┌─────────────────┐
│   NodePort      │  ← localhost:30081
│   (30081)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Service       │  ← ClusterIP (8081)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Pods (1-10)  │  ← Auto-scaled by HPA
└─────────────────┘
```

## Troubleshooting

### Check pod status
```bash
kubectl get pods -n service-ns
```

### View logs
```bash
kubectl logs -n service-ns -l app=service
```

### Check HPA
```bash
kubectl get hpa -n service-ns
kubectl describe hpa -n service-ns
```

### Test endpoint
```bash
curl localhost:30081/api/v1/data
```
