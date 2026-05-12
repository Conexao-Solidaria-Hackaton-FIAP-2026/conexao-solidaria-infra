# apply-all.ps1
# Executa apos "docker build" em cada servico e "minikube image load"

param(
    [switch]$LoadImages
)

$ErrorActionPreference = "Stop"
Write-Host "=== Aplicando manifests no Minikube ===" -ForegroundColor Cyan

if ($LoadImages) {
    Write-Host "Carregando imagens no Minikube..." -ForegroundColor Yellow
    minikube image load campaigns-api:latest
    minikube image load donation-worker:latest
}

kubectl apply -f k8s/namespace.yaml

Write-Host "Subindo banco e broker..." -ForegroundColor Yellow
kubectl apply -f k8s/sqlserver/
kubectl apply -f k8s/rabbitmq/

Write-Host "Aguardando SQL Server ficar pronto (pode demorar ~30s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "Subindo APIs..." -ForegroundColor Yellow
kubectl apply -f k8s/campaigns-api/
kubectl apply -f k8s/donation-worker/

Write-Host "Subindo observabilidade..." -ForegroundColor Yellow
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/

Write-Host ""
Write-Host "Aguardando pods ficarem prontos..." -ForegroundColor Yellow
kubectl wait --for=condition=Ready pod -l app=campaigns-api  -n conexao-solidaria --timeout=120s
kubectl wait --for=condition=Ready pod -l app=donation-worker -n conexao-solidaria --timeout=120s

Write-Host ""
Write-Host "=== STATUS DOS PODS ===" -ForegroundColor Green
kubectl get pods -n conexao-solidaria

$ip = minikube ip
Write-Host ""
Write-Host "=== URLS ===" -ForegroundColor Green
Write-Host "  campaigns-api : http://${ip}:30080/swagger"
Write-Host "  Prometheus    : http://${ip}:30090"
Write-Host "  Grafana       : http://${ip}:30300  (admin/admin)"
Write-Host ""
Write-Host "RabbitMQ Management (port-forward necessario):" -ForegroundColor Yellow
Write-Host "  kubectl port-forward svc/rabbitmq-svc 15672:15672 -n conexao-solidaria"
Write-Host "  Acesse: http://localhost:15672  (guest/guest)"
