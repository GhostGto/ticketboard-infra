#!/bin/bash

set -e

echo "=== Deploying Ticketboard Platform ==="

# Build and push images
echo "Building and pushing images..."

# Backend
echo "Building backend image..."
docker build -t localhost:5000/backend:latest ../ticketboard-backend
docker push localhost:5000/backend:latest

# Frontend
echo "Building frontend image..."
docker build -t localhost:5000/frontend:latest ../ticketboard-frontend
docker push localhost:5000/frontend:latest

# Apply all Kubernetes manifests with Kustomize
echo "Applying Kubernetes manifests..."

# Apply base resources
kubectl apply -k k8s/base/

# Apply database
kubectl apply -k k8s/database/

# Wait for database to be ready
echo "Waiting for database to be ready..."
./scripts/wait-for-db.sh

# Apply backend
kubectl apply -k k8s/backend/

# Apply frontend
kubectl apply -k k8s/frontend/

# Wait for deployments
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n ticketboard --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n ticketboard --timeout=300s

# Run database migrations
echo "Running database migrations..."
kubectl exec deployment/backend -n ticketboard -- npx prisma migrate deploy

echo "=== Deployment complete! ==="
echo "Access your application at: http://localhost"
echo "Backend API at: http://localhost/api"#!/bin/bash

set -e

echo "=== Deploying Ticketboard Platform ==="

# Build and push images
echo "Building and pushing images..."
#!/bin/bash

echo "🚀 Deploying TicketBoard application..."

# Start local registry
echo "🐳 Starting local registry..."
docker run -d -p 5000:5000 --name registry registry:2

# Wait for registry
sleep 5

# Deploy to Kubernetes
echo "📦 Deploying to Kubernetes..."
kubectl apply -k k8s/overlays/development

echo "⏳ Waiting for deployment to complete..."
kubectl wait --for=condition=ready pod -l app=postgres -n ticketboard --timeout=180s

echo "✅ Deployment completed!"
kubectl get all -n ticketboard