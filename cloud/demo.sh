#!/bin/bash
# =============================================================================
# Cloud — Live demonstration (3 min)
# =============================================================================
# Sådan bruges dette script:
#   1. Åbn i VS Code og gennemgå hvert trin
#   2. Kør kommandoerne manuelt i terminalen — hav flere ruder klar
#   3. Forudfyld VM-IP og ACR-navn nedenfor
#
# Kræver:
#   - Azure CLI installeret (til NSG-delen)
#   - SSH-nøgle til VM'en
#   - Docker image allerede bygget og pushet via deploy.yml
# =============================================================================

# ─── Konfiguration ───────────────────────────────────────────────────────────
VM_IP="20.xx.xx.xx"                # Erstat med din VMs offentlige IP
VM_USER="azureuser"                # Brugernavn på VM'en
ACR_SERVER="myregistry.azurecr.io" # Dit ACR login-server navn
IMAGE_NAME="my-app"                # Docker image navn
PORT=8080                          # Applikationens port

# ──────────────────────────────────────────────────────────────────────────────
# DEMO 1: Vis CD workflow-filen
# ──────────────────────────────────────────────────────────────────────────────
# Åbn .github/workflows/deploy.yml i VS Code
# Peg på:
#   - Trigger: push til main + workflow_dispatch:
#   - azure/docker-login@v2 — login til ACR med secrets
#   - docker build -t ... ./docker  — byg fra docker/-mappen
#   - docker push — skub til ACR
#
# Ekstra: Vis GitHub UI → Actions → "CD — Byg og push til ACR" → Run workflow
echo "────────────────────────────────────────────────────────────"
echo "  DEMO 1: Vis .github/workflows/deploy.yml"
echo "────────────────────────────────────────────────────────────"
echo "Åbn filen i VS Code:"
echo "  code .github/workflows/deploy.yml"
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# DEMO 2: SSH-indlogning på cloud VM
# ──────────────────────────────────────────────────────────────────────────────
echo "────────────────────────────────────────────────────────────"
echo "  DEMO 2: Log ind på cloud VM"
echo "────────────────────────────────────────────────────────────"
echo ""
echo "Kør:"
echo "  ssh ${VM_USER}@${VM_IP}"
echo ""
echo "Forvent:"
echo "  Welcome to Ubuntu ..."
echo "  azureuser@vm-name:~$"
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# DEMO 3: Vis kørende Docker-container på VM'en
# ──────────────────────────────────────────────────────────────────────────────
# Køres på VM'en efter SSH
echo "────────────────────────────────────────────────────────────"
echo "  DEMO 3: Vis kørende container (kør på VM'en)"
echo "────────────────────────────────────────────────────────────"
echo ""
echo "Træk nyeste image:"
echo "  docker pull ${ACR_SERVER}/${IMAGE_NAME}:latest"
echo ""
echo "Kør containeren:"
echo "  docker run -d \\"
echo "    --name my-app \\"
echo "    --restart unless-stopped \\"
echo "    -p ${PORT}:${PORT} \\"
echo "    ${ACR_SERVER}/${IMAGE_NAME}:latest"
echo ""
echo "Vis kørende containere:"
echo "  docker ps"
echo ""
echo "Forvent output:"
echo "  CONTAINER ID   IMAGE                                   ...   PORTS"
echo "  abc123def456   myregistry.azurecr.io/my-app:latest     ...   0.0.0.0:8080->8080/tcp"
echo ""
echo "Vis logs:"
echo "  docker logs my-app"
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# DEMO 4: Vis / ændr NSG firewall-regel
# ──────────────────────────────────────────────────────────────────────────────
# Alternativ A: Azure Portal
echo "────────────────────────────────────────────────────────────"
echo "  DEMO 4A: NSG firewall — Azure Portal"
echo "────────────────────────────────────────────────────────────"
echo ""
echo "1. Åbn browser → portal.azure.com"
echo "2. Søg efter VM'en → Networking"
echo "3. Vis inbound-regler: SSH (22), HTTP (8080)"
echo "4. Tilføj midlertidig regel ELLER fjern port 8080-reglen"
echo ""
echo "Alternativ: Azure CLI"
echo "────────────────────────────────────────────────────────────"
echo ""
echo "Se nuværende NSG-regler:"
echo "  az network nsg rule list \\"
echo "    --resource-group <rg-navn> \\"
echo "    --nsg-name <nsg-navn> \\"
echo "    --output table"
echo ""
echo "Fjern port 8080 (vis at app ikke længere er tilgængelig):"
echo "  az network nsg rule delete \\"
echo "    --resource-group <rg-navn> \\"
echo "    --nsg-name <nsg-navn> \\"
echo "    --name Allow-HTTP-8080"
echo ""
echo "Genåbn port 8080:"
echo "  az network nsg rule create \\"
echo "    --resource-group <rg-navn> \\"
echo "    --nsg-name <nsg-navn> \\"
echo "    --name Allow-HTTP-8080 \\"
echo "    --protocol tcp \\"
echo "    --priority 110 \\"
echo "    --destination-port-range ${PORT} \\"
echo "    --access Allow"
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# DEMO 5: Bekræft app kører i browseren
# ──────────────────────────────────────────────────────────────────────────────
echo "────────────────────────────────────────────────────────────"
echo "  DEMO 5: Bekræft app i browser"
echo "────────────────────────────────────────────────────────────"
echo ""
echo "Åbn browser:"
echo "  http://${VM_IP}:${PORT}"
echo ""
echo "Forvent:"
echo "  <h1> Docker Demo App </h1>"
echo "  <p>Container kører! Image bygget med multi-stage build.</p>"
echo ""
echo "─ Med firewall-regel:    ✅ Siden vises"
echo "─ Uden firewall-regel:   ❌ Connection timeout"
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# NYTTIGE KOMMANDOER
# ──────────────────────────────────────────────────────────────────────────────
echo "────────────────────────────────────────────────────────────"
echo "  Ekstra: Nyttige VM-kommandoer"
echo "────────────────────────────────────────────────────────────"
echo ""
echo "Opdater container til nyeste image:"
echo "  docker stop my-app && docker rm my-app"
echo "  docker pull ${ACR_SERVER}/${IMAGE_NAME}:latest"
echo "  docker run -d --name my-app --restart unless-stopped -p ${PORT}:${PORT} ${ACR_SERVER}/${IMAGE_NAME}:latest"
echo ""
echo "Se Docker container logs:"
echo "  docker logs -f my-app"
echo ""
echo "Ryd op (fjern container og image):"
echo "  docker stop my-app && docker rm my-app"
echo "  docker rmi ${ACR_SERVER}/${IMAGE_NAME}:latest"
echo ""
echo "Se VM'ens ressourceforbrug:"
echo "  top"
echo "  df -h"
echo ""
