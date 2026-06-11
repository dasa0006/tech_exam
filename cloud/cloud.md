# Cloud — Eksamensdisposition

**Varighed:** 15 minutter
**Formål:** Forstå cloud-begreber (IaaS/PaaS), kunne deploye en applikation i cloud'en og håndtere sikkerhed (firewall, port-konfiguration)

**Cloud-leverandør i undervisningen:** Microsoft Azure

> **Note til eksaminator:** Cloud-emnet hænger tæt sammen med Docker, CI/CD og Linux-terminalen. Forvent spørgsmål på tværs af emner.

---

## 1. IaaS vs PaaS — grundbegreber (2 min)

### De tre "as-a-service"-modeller

| Model | Hvad får du? | Hvad styrer du selv? | Eksempler |
|-------|-------------|----------------------|-----------|
| **IaaS** | Virtuelle maskiner, netværk, storage | OS, runtime, app, data | Azure VM, AWS EC2, DigitalOcean |
| **PaaS** | Platform (OS + runtime inkluderet) | App, data | Azure App Service, AWS Elastic Beanstalk, Heroku |
| **SaaS** | Færdig applikation | Data (indhold) | Office 365, Gmail |

### Hvad har du brugt?

- **IaaS:** Azure VM med Linux — selv styret OS, Docker installeret manuelt
- **PaaS:** (Hvis relevant — fx database som service, Azure SQL / PostgreSQL managed)

### Ansvarsmodel (shared responsibility)

```text
┌─────────────────────────────────────┐
│  Data & adgangskontrol              │  ← Kunden (dig)
├─────────────────────────────────────┤
│  Applikation                        │
├─────────────────────────────────────┤
│  Runtime (Java, Node, …)            │
├──────────────────┬──────────────────┤
│  OS (patches)    │                  │  ← IaaS: kunde / PaaS: cloud
├──────────────────┤   PaaS           │
│  Container       │                  │
├──────────────────┤                  │
│  Virtuel hardware │                  │
├──────────────────┤                  │
│  Fysisk hardware  │                  │  ← Cloud-leverandør
├──────────────────┴──────────────────┤
│  Netværk, datacenter, strøm         │
└─────────────────────────────────────┘
```

> **Sig:** "Jo længere op i modellerne, jo mindre har jeg selv ansvar for — men også mindre kontrol. IaaS giver mig fuld fleksibilitet, PaaS tager sig af OS og runtime."

---

## 2. Cloud-produkter ud over VM'er (2 min)

### Kategorier af cloud-services

| Kategori | Eksempler (Azure) | Formål |
|----------|-------------------|--------|
| **Compute** | VM, App Service, Azure Functions, AKS | Kørsel af applikationer |
| **Storage** | Blob Storage, Disk, File Share | Filer, backups, statisk indhold |
| **Database** | Azure SQL, PostgreSQL, MySQL managed | Relationelle databaser — backup, failover inkluderet |
| **Netværk** | VNet, Load Balancer, DNS, CDN | Forbindelse og distribution |
| **Container** | Azure Container Registry, ACI, AKS | Docker-image registry og orkestrering |
| **Serverless** | Azure Functions, Logic Apps | Event-drevet kode uden at tænke på servere |
| **Sikkerhed** | Key Vault, NSG (firewall), Azure AD | Nøgler, certifikater, adgangskontrol |

> **Sig:** "Cloud handler ikke kun om VM'er — der findes specialiserede tjenester til næsten alt: managed databaser, containerorkestrering, serverless functions. Man vælger den rette service baseret på behov for kontrol vs. bekvemmelighed."

### Hvad du selv har brugt

- **Azure VM** — IaaS, selvstyret
- **Azure Container Registry (ACR)** — opbevaring af Docker images
- **(Evt.) Azure App Service** — PaaS til webapplikationer

> **Pointer:** "Til vores Spring Boot-app brugte vi en VM (IaaS) + Docker i stedet for PaaS, fordi det gav os fuld kontrol og lærte os infrastruktur."

---

## 3. Deploy af Spring Boot-app i cloud'en (4 min)

### Tre måder at deploye på

```
Spring Boot-app (.jar)
        │
        ├── IaaS: VM + Docker
        │     └── Mest kontrol, selv ansvar for OS, Docker, updates
        │
        ├── PaaS: Azure App Service
        │     └── Mindre kontrol, men lettere — upload jar, platform styrer resten
        │
        └── Container: Azure ACI / AKS
              └── Orkestreret — godt ved microservices / skaleringsbehov
```

### IaaS-tilgangen trin for trin (med Docker)

1. **Byg Docker image i CI/CD** — GitHub Actions bygger og pusher til Azure Container Registry
2. **Log ind på VM via SSH** — `ssh azureuser@<vm-ip>`
3. **Træk image** — `docker pull <acr-name>.azurecr.io/my-app:latest`
4. **Kør container** — `docker run -d -p 8080:8080 --name my-app <image>`
5. **Åbn firewall** — Tillad trafik på port 8080 i VM's NSG (Network Security Group)

```bash
# På cloud VM'en
ssh azureuser@20.xx.xx.xx
docker pull myregistry.azurecr.io/my-app:latest
docker run -d -p 8080:8080 --restart unless-stopped myregistry.azurecr.io/my-app:latest
```

> **Demonstration:** Vis CD-delen af GitHub Actions-workflow'et (byg → push til ACR). Vis SSH-indlogning på VM'en. Vis `docker ps` på VM'en.

### CD-pipeline (GitHub Actions → ACR → VM)

```yaml
# Uddrag af CD-workflow
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Login to Azure Container Registry
        uses: azure/docker-login@v1
        with:
          login-server: myregistry.azurecr.io
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}

      - name: Build and push Docker image
        run: |
          docker build -t myregistry.azurecr.io/my-app:${{ github.sha }} .
          docker push myregistry.azurecr.io/my-app:${{ github.sha }}
```

> **Sig:** "CI/CD sikrer at hver `git push` til main automatisk bygger et nyt image og pusher det til registry. Herefter trækker jeg det manuelt på VM'en — eller automatisere med en deploy action."

### Alternativ: PaaS (Azure App Service)

- Upload `.jar` eller forbind til GitHub → auto-deploy
- Platformen håndterer OS, runtime, SSL, skalering
- Mindre kontrol, men væsentligt mindre operationsarbejde

> **Pointer:** "IaaS giver mig kontrol og læring. PaaS er hurtigere til produktion, men giver mindre indsigt i hvad der foregår under motorhjelmen."

---

## 4. Sikkerhed: Firewall og port-konfiguration (3 min)

### Cloud firewall — Network Security Groups (NSG)

- **NSG:** Cloud-firewall på Azure VM-niveau / subnet-niveau
- Regler for **indgående** (inbound) og **udgående** (outbound) trafik
- **Default:** Al indgående trafik er blokeret — man skal eksplicit åbne porte

```text
NSG-regel eksempel:
  Priority: 100
  Name:     Allow-SSH
  Port:     22
  Protocol: TCP
  Source:   Any (eller din IP)
  Action:   Allow
```

> **Demonstration:** Vis i Azure Portal (eller CLI) hvordan man tilføjer/fjerner en firewall-regel. Vis før/når port 8080 er lukket vs åben.

### Docker port-konfiguration og sikkerhed (krydsreference til Docker-emnets port-mapping)

- **`-p 8080:8080`** — binder til `0.0.0.0` (alle netværksinterfaces)
- **`-p 127.0.0.1:8080:8080`** — binder kun til localhost (på VM'en)
- **Sikkerhedsimplikation:** Cloud-firewall (NSG) er første forsvarslinje. Port-binding inden i VM'en er andet lag.

```text
Internet ──→ [NSG: port 8080 åben] ──→ VM ──→ [Docker: -p 8080:8080] ──→ App
```

**Hvorfor bekymre sig?**
- Hvis NSG tillader port 8080 fra hele internettet, og Docker binder til `0.0.0.0`, er app'en eksponeret for alle
- **Principle of least access:** Åbn kun porte der er nødvendige, og kun fra de IP-adresser der skal bruge dem
- Overvej: Skal SSH (port 22) være åben fra hele internettet, eller kun fra din IP?

> **Sig:** "Firewall i cloud er dit første sikkerhedslag. Docker port-binding er det andet. Sammen bestemmer de præcis, hvem der kan nå din applikation."

### Tjekliste for sikker cloud-deploy

| Tiltag | Hvorfor |
|--------|---------|
| Åbn kun nødvendige porte i NSG | Reducer angrebsflade |
| Bind Docker til `127.0.0.1` for interne services | Ingen ekstern adgang uden NSG-gennemgang |
| Brug SSH-nøgler i stedet for password | Stærk autentifikation |
| Hold VM opdateret (patches) | Sikkerhedsopdateringer |
| Kør container med `--restart unless-stopped` | Automatisk genstart ved reboot |

---

## 5. Live demonstration (3 min)

### Scenario: Vis en cloud-deployet Spring Boot-app

**Forberedt på computeren:**

1. **Vis GitHub Actions workflow-filen** — peg på CD-delen (byg, push til ACR)
   ```bash
   # .github/workflows/deploy.yml — vis i VS Code
   ```

2. **Log ind på cloud VM** med SSH
   ```bash
   ssh azureuser@20.xx.xx.xx
   ```

3. **Vis kørende Docker-container** på VM'en
   ```bash
   docker ps
   # Forvent: my-app container kører, port 8080
   ```

4. **Vis / ændr NSG firewall-regel**
   - Åbn Azure Portal → VM → Networking
   - Vis eksisterende inbound-regler (SSH:22, HTTP:8080)
   - Tilføj midlertidig regel eller fjern en regel → vis at app ikke længere er tilgængelig

5. **Bekræft app kører** i browseren: `http://20.xx.xx.xx:8080`

> **Tidsstyring:** Hold demonstrationen stram. Hav alle kommandoer i en terminalhistorik eller script, så du ikke skal skrive fra bunden.

---

## 6. Afrunding (1 min)

- **IaaS** (Azure VM) giver fuld kontrol — **PaaS** (Azure App Service) giver mindre vedligehold
- Cloud handler om **managed services** — vælg rette værktøj til opgaven
- Deploy-flow: **Build (CI) → Push (ACR) → Pull (VM) → Run (Docker)**
- **Sikkerhed i lag:** NSG (cloud firewall) + Docker port-binding + SSH-nøgler
- Firewall-regler og port-konfiguration hænger direkte sammen — forstå begge

---

## Forberedte eksempler på computeren

| # | Demonstration | Fil / sted |
|---|---------------|------------|
| 1 | CD-delen af GitHub Actions-workflow (byg + push til ACR) | `.github/workflows/deploy.yml` — CD workflow |
| 2 | SSH-indlogning på cloud VM | Terminal — `ssh azureuser@<vm-ip>` |
| 3 | Vis kørende Docker-container på VM | Terminal på VM — `docker ps` |
| 4 | Vis/ændr NSG firewall-regler | Azure Portal → VM → Networking, eller Azure CLI (`cloud/demo.sh`) |
| 5 | App'en i browseren (med og uden firewall-regel) | `http://<vm-ip>:8080` |
| — | **Hele demo-flowet samlet** | **`cloud/demo.sh`** — demo-manuskript med alle kommandoer |

---

## Forventede opfølgende spørgsmål fra eksaminator

- *Hvad er forskellen på IaaS og PaaS? Hvad har du brugt?*
- *Hvilke cloud-produkter kender du ud over VM'er?*
- *Hvordan deployer du en Spring Boot-app i cloud'en?*
- *Hvordan påvirker Docker port-konfiguration sikkerheden?*
- *Hvordan hænger NSG-firewall og Docker port-mapping sammen?*
- *Hvorfor bruge IaaS i stedet for PaaS til din app?*
- *Hvad sker der hvis du åbner port 3306 (MySQL) til hele internettet?*
- *Hvordan ville du automatisere deploy fra ACR til VM'en?* (fx watchtower, GitHub Actions deploy step)
- *Hvordan adskiller Azure Container Registry sig fra Docker Hub?*
- *Hvad er forskellen på `-p 8080:8080` og `-p 127.0.0.1:8080:8080` i en cloud-kontekst?*
