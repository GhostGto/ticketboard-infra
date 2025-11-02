#!/bin/bash

echo "=== Setting up Kind cluster ==="

# Limpiar clusters existentes
echo "🧹 Cleaning existing clusters..."
kind get clusters | while read cluster; do
  kind delete cluster --name "$cluster" 2>/dev/null || true
done

# Crear registry
echo "🐳 Creating registry..."
docker run -d --restart=always -p 5000:5000 --name registry registry:2

# Crear cluster
echo "🚀 Creating Kind cluster..."
kind create cluster --name ticketboard --wait 5m

# Conectar registry
echo "🔗 Connecting registry..."
docker network connect kind registry || true

# Configurar kubectl
echo "⚙️ Configuring kubectl..."
kind export kubeconfig --name ticketboard

echo "✅ Cluster setup completed!"
kubectl cluster-info
kubectl get nodes