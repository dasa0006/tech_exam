# CI/CD, GitHub Actions — Eksamensdisposition

**Varighed:** 15 minutter
**Formål:** Forklare CI/CD-begreber og demonstrere GitHub Actions-færdigheder

---

## 1. Hvad er CI/CD? (1,5 min)

- **Continuous Integration (CI):** Hyppig integration af kodeændringer → automatisk byg og test
- **Continuous Deployment (CD):** Automatisk deploy af godkendt kode til produktion/staging
- **GitHub Actions som CI/CD-platform:** Workflows defineret i YAML i `.github/workflows/`

> **Sig:** "CI handler om at fange fejl tidligt.
>   GitHub Actions lader os definere hele pipeline som kode."

---

## 2. GitHub Actions' byggeblokke (3 min)

### Workflow-struktur

- **`jobs:`** — logiske enheder, kører på separate runners (kan køre parallelt eller sekventielt med `needs:`)
- **`steps:`** — enkeltskridt inden i et job (køres sekventielt)
- **`uses:`** — genbrug af eksisterende actions fra Marketplace (fx `actions/checkout@v4`)
- **`run:`** — udfører vilkårlige shell-kommandoer direkte i workflow'et

### Konkrete eksempler på `run:`

- `run: mvn test` — kør tests
- `run: echo "Byg færdig"`
- `run: |` — flerlinjede scripts (fx byg, test, lint i samme step)

> **Vis forskellen:** `uses:` importerer en færdig action.
>   `run:` kører det, du selv skriver — mere fleksibelt, men mere kode at vedligeholde.

### Trigger-events

- `push:`, `pull_request:`, `workflow_dispatch:` (manuel trigger)

> **Demonstration:** Vis et simpelt workflow for Java + Maven
>   (byg → test → upload artifact)

---

## 3. Typiske CI-tjek (2,5 min)

- **Build:** `mvn compile` — kompilerer koden
- **Test:** `mvn test` — kør enhedstests
- **Lint / statisk analyse:** `mvn checkstyle:check` eller `mvn pmd:pmd`
- **Integrationstests:** `mvn verify` — kører også integrationstests (`failsafe-plugin`)

### Maven's build lifecycle i CI

| Fase     | Formål                          | Bruges i CI? |
|----------|---------------------------------|--------------|
| compile  | Kompiler kode                   | Ja           |
| test     | Kør enhedstests                 | Ja           |
| package  | Byg jar/war                     | Ja           |
| verify   | Kør integrationstests           | Ofte         |
| install  | Læg i lokal repository          | Sjældent     |
| deploy   | Upload til remote repository    | Ved CD       |

> **Pointer:** `mvn verify` kører hele cycle — typisk det, man bruger i CI.
>   Undgå `install` og `deploy` medmindre du publicerer.

---

## 4. Caching og hash-pinning (3 min)

### Caching af Maven-dependencies

- **Problem:** Hentning af 3rd-party jars tager lang tid hver gang
- **Løsning:** `actions/cache@v4`
- **Cache key:** Typisk en hash af `pom.xml` (eller `pom.xml` + lock-fil)
  - `key: ${{ runner.os }}-maven-${{ hashFiles('**/pom.xml') }}`
  - `restore-keys:` — fallback til delvis match ved miss

> **Demonstration:** Vis hvordan `actions/cache@v4` tilføjes til workflow'et
>   med `path: ~/.m2/repository`

### Hash-pinning af actions

- **Problem:** At referere til en action via tag (`@v4`) kan ændre sig
- **Løsning:** Pin til commit-SHA (`@abc123def...`)
  - Fordel: Reproducerbare builds, sikkerhed mod supply chain attacks
  - Ulempe: Skal manuelt opdateres ved nye versioner
- **Dependabot** kan automatisere opdatering af pinned commits

> **Demonstration:** Find commit-SHA for `actions/checkout@v4` og
>   erstat `@v4` med SHA'en.

---

## 5. Manuel trigger og Docker i CI (2,5 min)

### `workflow_dispatch:`

- Tilføjes som event i workflow-filen
- Gør det muligt at køre workflow manuelt via GitHub UI
- Nyttigt til ad-hoc tests, manuelt deploy, genkørsel

> **Demonstration:** Åbn et workflow med `workflow_dispatch:`,
>   tryk på "Run workflow" i GitHub UI.

### Byg og upload Docker images i CI

- **Byg:** `docker/build-push-action@v5` eller `run: docker build .`
- **Upload til GitHub Container Registry (ghcr.io):**
  - `docker/login-action@v3` — login til GHCR
  - `docker/build-push-action@v5` — byg + push i ét step
- **CD-delen:** Workflow kører ved `push` til `main` → bygger image → pusher → deployer

---

## 6. Live demonstration (2,5 min)

Vis ét workflow, der samler koncepterne:

1. **Trigget** af `push` og `workflow_dispatch:`
2. **Tjekker kode ud** med `actions/checkout@v4`
3. **Cacher** Maven-dependencies med `actions/cache@v4`
4. **Bygger og tester** med `run: mvn verify`
5. **Uploader artifact** med `actions/upload-artifact@v4`

> Peg på hver nøgleord mens du forklarer:
>   `jobs:` → `steps:` → `uses:` → `run:` → caching.

---

## 7. Afrunding (30 sek)

- CI/CD handler om **automatisering og kvalitet**
- GitHub Actions gør pipeline-as-code let tilgængeligt
- Nøgleord: jobs/steps, uses/run, caching, hash-pinning, workflow_dispatch

---

## Forberedte eksempler på computeren

| # | Demonstration | Fil / sted |
|---|---------------|------------|
| 1 | GitHub Actions-fil med Maven-test | `.github/workflows/ci.yml` i et Java-projekt |
| 2 | Caching af Maven-dependencies | Samme fil med `actions/cache@v4` tilføjet |
| 3 | `workflow_dispatch:` tilføjet og kørt | Samme fil med `workflow_dispatch:` event |
| 4 | Hash-pinning af én action | Erstat `@v4` med commit-SHA |

---

## Forventede opfølgende spørgsmål fra eksaminator

- *Hvad er forskellen på `mvn test` og `mvn verify`?*
- *Hvorfor cache'er vi `~/.m2/repository` og ikke hele projektet?*
- *Hvad sker der hvis cache key matcher — og hvis den ikke gør?*
- *Hvordan adskiller Docker-images bygget i CI sig fra lokalt byggede?*
- *Hvad er ulempen ved hash-pinning?*
