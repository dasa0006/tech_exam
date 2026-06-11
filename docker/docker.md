# Docker, Docker Compose, Dockerfile — Eksamensdisposition

**Varighed:** 15 minutter
**Formål:** Forklare containers fundament, Dockerfile-opbygning og Docker Compose-orchestrering

---

## 1. Dockerfile, Image, Container — de tre grundbegreber (2 min)

- **Dockerfile:** Opskrift / byggeinstruktion (tekstfil med `FROM`, `COPY`, `RUN` osv.)
- **Image:** Kompileret, read-only snapshot af en Dockerfile (distribueres via registry)
- **Container:** Kørende instans af et image (har eget filsystem, netværk, PID namespace)

> **Sig:** "Dockerfile er opskriften. Image er det frosne måltid. Containeren er den varme ret på tallerkenen."

### Relationen

```text
Dockerfile  --(docker build)-->  Image  --(docker run)-->  Container
```

> **Demonstration:** Kør `docker images` og `docker ps` for at vise forskellen mellem images og containere.

---

## 2. Dockerfile i dybden (3 min)

### Opbygning og build cache

- **`FROM maven:3.9.9-eclipse-temurin-21`** — base image med Java 21 + Maven
  - Hvert lag i en Dockerfile bliver et **cache-lag**
  - Build cache: Hvis en instruktion og dens kontekst ikke har ændret sig, genbruges det cached lag
  - **Optimering:** Placer sjældent ændrede instruktioner øverst (installer dependencies før COPY af kildekode)

```dockerfile
# Optimér build cache — ofte ændret nederst
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .                  # Kun pom.xml — cachebar
RUN mvn dependency:resolve     # Download af dependencies — cachebar
COPY src .                     # Først nu kopieres kode
RUN mvn package
```

> **Demonstration:** Tag en Dockerfile fra undervisningen og peg på hver instruktion (FROM, WORKDIR, COPY, RUN). Vis hvordan omrokering af `COPY pom.xml` forbedrer cache-traf.

### Multi-stage builds

- **Problem:** Byggeværktøj og SDK fylder i det endelige image
- **Løsning:** Første stage bygger, anden stage kopierer kun artifact (jar)
- **Resultat:** Lille, produktionsklar image uden unødvendige værktøjer

```dockerfile
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:resolve
COPY src .
RUN mvn package

FROM eclipse-temurin:21-jre AS runtime
WORKDIR /app
COPY --from=build /app/target/app.jar .
CMD ["java", "-jar", "app.jar"]
```

> **Pointer:** `--from=build` refererer til første stage. Slut-image er kun JRE + jar — ingen Maven, ingen compiler.

### COPY vs volumes — hvornår bruges hvad?

| Værktøj | Hvornår | Formål |
|---------|---------|--------|
| `COPY` (Dockerfile) | **Byggetid** | Læg kode/jar ind i image — statisk |
| `volumes:` (compose.yaml) | **Kørselstid** | Del filer mellem host og container — dynamisk / udvikling |

> **Sig:** "COPY bages ind i imagen og er med uanset hvor det kører. Volumes monteres ved kørsel — perfekt til konfiguration eller udvikling, hvor koden ændres live."

---

## 3. Docker Compose (3 min)

### Hvorfor Docker Compose?

- **Problem:** `docker run` med mange flags (`--network`, `-v`, `-e`, `-p`) er uoverskueligt
- **Løsning:** `compose.yaml` — declarativ YAML-fil, der beskriver hele applikationen (services, netværk, volumes)
- Én kommando: `docker compose up -d` starter alting

### `image:` vs `dockerfile:` i compose.yaml

```yaml
services:
  db:
    image: mysql:8.0          # Brug færdigbygget image fra Docker Hub
  app:
    dockerfile: Dockerfile    # Byg lokalt ud fra Dockerfile i mappen
```

- **`image:`** — træk og kør et eksisterende image (database, cache, osv.)
- **`dockerfile:`** — byg et custom image til din egen applikation

### Port mapping — `8080:8080` vs `127.0.0.1:3307:3306`

```yaml
services:
  web:
    ports:
      - "8080:8080"              # Alle interfaces: host:8080 → container:8080
  db:
    ports:
      - "127.0.0.1:3307:3306"   # Kun localhost: host:3307 → container:3306
```

- Format: `[host-ip:]host-port:container-port`
- **Sikkerhed:** Bind til `127.0.0.1` hvis kun lokale processer skal have adgang (fx database)
- `0.0.0.0` (default) betyder alle netværksinterfaces — også eksterne

> **Demonstration:** Forklar en simpel `compose.yaml` (fx MySQL + app) og kør `docker compose up -d`.

---

## 4. Build cache-optimering og administration (2 min)

### Optimering af build cache for Dockerfile

- Kopiér først `pom.xml`/`package.json`, løs dependencies, *derefter* kopiér kode
- Hvorfor: Kildekode ændres ofte — dependencies sjældent
- Brug `.dockerignore` til at undgå at invalidere cache med unødvendige filer (`.git`, `node_modules/`, `target/`)

```dockerfile
# Dårlig rækkefølge — cache brydes ved hver kodeændring
COPY . .
RUN mvn dependency:resolve
RUN mvn package

# God rækkefølge — cache bevares for dependencies
COPY pom.xml .
RUN mvn dependency:resolve
COPY . .
RUN mvn package
```

### Container-livscyklus administration

```bash
docker start/stop/rm <container>   # Start, stop, slet container
docker ps -a                        # Vis alle containere (også stoppede)
docker rm $(docker ps -aq)          # Slet alle stopppede containere
docker images                       # Vis images
docker rmi <image>                  # Slet image
docker system prune                 # Ryd op i ubrugte: images, containere, cache, netværk
docker system prune -a              # Som ovenfor + alle cached images (ikke kun dangling)
```

> **Demonstration:** `docker system prune` og vis forskellen på `docker ps` (running) vs `docker ps -a` (alle).

---

## 5. Live demonstration (3,5 min)

### Scenario: Byg og kør en simpel Spring Boot-app med MySQL

**Skærm klar med tre terminalruder (eller sekventielt):**

1. **Vis Dockerfile** — peg på `FROM`, multi-stage, COPY-rækkefølge for build cache
   ```bash
   docker build -t my-app .
   ```

2. **Vis compose.yaml** — forklar services (`app` + `db`), port mapping, volumes
   ```yaml
   services:
     db:
       image: mysql:8.0
       environment:
         MYSQL_ROOT_PASSWORD: secret
       ports:
         - "127.0.0.1:3307:3306"
       volumes:
         - db-data:/var/lib/mysql
     app:
       dockerfile: Dockerfile
       ports:
         - "8080:8080"
       environment:
         SPRING_DATASOURCE_URL: jdbc:mysql://db:3306/mydb

   volumes:
     db-data:
   ```

   ```bash
   docker compose up -d
   ```

3. **Vis kørende containere og logud** — `docker compose logs -f`
4. **Ryd op** — `docker compose down -v` (fjern også volumes)

5. **Ekstra: Build cache-effekt** — Kør `docker build` igen uden kodeændring → "Using cache" for alle lag
   - Foretag en lille ændring i `src/` → kun sidste lag genbygges

> Peg på: cached vs uncached lag i build output.

---

## 6. Afrunding (30 sek)

- **Dockerfile:** Opskrift → Image → Container
- **Multi-stage builds:** Lille produktionsimage
- **Docker Compose:** Declarativ applikation med flere services
- **Build cache:** Rækkefølgen af instruktioner er altafgørende
- **Administration:** `docker ps`, `docker system prune` til at holde styr på ressourcer

---

## Forberedte eksempler på computeren

| # | Demonstration | Fil / sted |
|---|---------------|------------|
| 1 | Dockerfile med multi-stage build | Java-projekt med `Dockerfile` |
| 2 | Build cache-visning (med og uden ændring) | Samme Dockerfile — kør `docker build` to gange |
| 3 | `compose.yaml` for app + MySQL | Projektrod med `compose.yaml` |
| 4 | Start/stop/ryd op — `docker ps`, `docker compose down`, `docker system prune` | Terminal |
| 5 | Kør container med `-it` (simpelt eksempel) | `docker run -it ubuntu bash` |

---

## Forventede opfølgende spørgsmål fra eksaminator

- *Hvad er forskellen på et Docker image og en container?*
- *Hvorfor giver multi-stage builds et mindre image?*
- *Hvornår vil du bruge volumes i stedet for COPY?*
- *Hvad betyder port-bindingsformatet `127.0.0.1:3307:3306` for sikkerheden?*
- *Hvordan virker Docker's build cache — hvad invaliderer det?*
- *Hvad sker der hvis du kører `docker system prune -a`?*
- *Hvordan deployerer man applikationen med Docker Compose til en server?*
- *Hvad er forskellen på `image:` og `dockerfile:` i compose.yaml?*
