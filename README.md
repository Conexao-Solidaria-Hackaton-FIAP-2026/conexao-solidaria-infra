# conexao-solidaria-infra

Repositorio de infraestrutura do projeto Conexao Solidaria.

## Pre-requisitos
- Docker Desktop com Kubernetes habilitado (ou Minikube)
- kubectl
- .NET 8 SDK (para buildar as imagens)

## Rodar local com Docker Compose (professores)

```bash
docker compose up --build
```

Servicos disponiveis:
| Servico       | URL                          |
|---------------|------------------------------|
| campaigns-api | http://localhost:8080/swagger |
| RabbitMQ UI   | http://localhost:15672        |
| Prometheus    | http://localhost:9090         |
| Grafana       | http://localhost:3000         |

## Rodar no Kubernetes (Minikube)

```powershell
# 1. Buildar imagens em cada repo de servico
cd ../conexao-solidaria-campaigns-api
docker build -t campaigns-api:latest .

cd ../conexao-solidaria-donation-worker
docker build -t donation-worker:latest .

# 2. Voltar para este repo e aplicar tudo
cd ../conexao-solidaria-infra
./k8s/apply-all.ps1 -LoadImages
```

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
dockerfiles/          # Dockerfiles de cada servico (copiar para cada repo)
prometheus/           # Config do Prometheus
grafana/              # Datasources e dashboards do Grafana
docker-compose.yml    # Para rodar tudo localmente
```
