#!/bin/bash

# Configurar el registry local primero
echo "🔧 Configurando registry local..."
docker stop registry 2>/dev/null || true
docker rm registry 2>/dev/null || true
docker run -d -p 5000:5000 --name registry registry:2

# Configurar Docker para registry inseguro
sudo mkdir -p /etc/docker
echo '{
  "insecure-registries": ["localhost:5000"]
}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
sleep 10

# Verificar registry
echo "✅ Registry configurado:"
curl -s http://localhost:5000/v2/_catalog | jq .
