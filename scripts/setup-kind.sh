#!/bin/bash

echo "=== Setting up Kind cluster ==="

# Crear registry local
echo "Creating local registry container..."
docker run -d --restart=always -p 5000:5000 --name kind-registry registry:2

# Crear cluster Kind
echo "Creating Kind cluster..."
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ticketboard-cluster
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
    endpoint = ["http://kind-registry:5000"]
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
  - containerPort: 30001
    hostPort: 30001
    protocol: TCP
EOF

# Conectar registry al cluster
echo "Connecting registry to cluster..."
docker network connect kind kind-registry || true

# Configurar kubectl
echo "Configuring kubectl context..."
kubectl cluster-info --context kind-ticketboard-cluster

# Instalar ingress-nginx
echo "Installing ingress-nginx..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Esperar a que ingress-nginx esté listo (con manejo de errores mejorado)
echo "Waiting for ingress controller to be ready..."
sleep 10

# Esperar con timeout y reintentos
for i in {1..30}; do
  if kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller | grep -q "Running"; then
    echo "✅ Ingress controller is ready!"
    break
  fi
  echo "⏳ Waiting for ingress controller... (attempt $i/30)"
  sleep 10
done

# Verificar estado final
echo "=== Cluster Setup Complete ==="
kubectl get nodes
kubectl get pods -n ingress-nginx
kubectl get all -A | grep ingress

echo "🚀 Kind cluster is ready for deployment!"