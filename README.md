# conexao-solidaria-infra

Repositorio de infraestrutura do projeto Conexao Solidaria.

## Pre-requisitos

- Docker Desktop
- Minikube
- kubectl
- .NET 10 SDK
- Git

## Estrutura de pastas esperada

Os tres repositorios devem estar na mesma pasta pai:

```
/repos
  /conexao-solidaria-api
  /conexao-solidaria-donation-worker
  /conexao-solidaria-infra        <- este repo
```

## Rodar local com Docker Compose

```bash
cd conexao-solidaria-infra
docker compose up --build
```

Servicos disponiveis:

| Servico       | URL                            | Credenciais   |
|---------------|--------------------------------|---------------|
| campaigns-api | http://localhost:8080/swagger  | -             |
| RabbitMQ UI   | http://localhost:15672         | guest / guest |
| Prometheus    | http://localhost:9090          | -             |
| Grafana       | http://localhost:3000          | admin / admin |

Credenciais do banco SQL Server: `sa / ConexaoSolidaria2026`

## Rodar no Kubernetes (Minikube)

```powershell
# 1. Iniciar o Minikube ANTES do Docker Compose
minikube start --driver=docker --memory=4096 --cpus=2

# 2. Subir o Docker Compose
docker compose up -d

# 3. Buildar as imagens
docker build -t campaigns-api:latest ../conexao-solidaria-api
docker build -t donation-worker:latest ../conexao-solidaria-donation-worker

# 4. Desbloquear e executar o script
Unblock-File ./k8s/apply-all.ps1
./k8s/apply-all.ps1 -LoadImages

# 5. Abrir os servicos (cada comando em um terminal separado)
kubectl port-forward svc/campaigns-api-svc 8080:8080 -n conexao-solidaria
kubectl port-forward svc/prometheus-svc 9090:9090 -n conexao-solidaria
kubectl port-forward svc/grafana-svc 3000:3000 -n conexao-solidaria
kubectl port-forward svc/rabbitmq-svc 15673:15672 -n conexao-solidaria
```

Apos subir, os servicos ficam disponiveis em:

| Servico       | URL                            | Credenciais   |
|---------------|--------------------------------|---------------|
| campaigns-api | http://localhost:8080/swagger  | -             |
| RabbitMQ UI   | http://localhost:15673         | guest / guest |
| Prometheus    | http://localhost:9090          | -             |
| Grafana       | http://localhost:3000          | admin / admin |

## Estrutura

```
k8s/                  # Manifestos Kubernetes
  namespace.yaml
  sqlserver/
  rabbitmq/
  campaigns-api/
  donation-worker/
  prometheus/
  grafana/
  apply-all.ps1       # Script para subir tudo no Minikube
dockerfiles/          # Dockerfiles de cada servico
prometheus/           # Config do Prometheus
grafana/              # Datasources e dashboards do Grafana
docker-compose.yml    # Para rodar tudo localmente
```