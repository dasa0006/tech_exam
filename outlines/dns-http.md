# DNS og HTTP(S) — Eksamensdisposition

**Varighed:** 15 minutter
**Formål:** Forklare DNS' rolle på internettet, HTTP-protokollens struktur og demonstrere værktøjer til fejlfinding

---

## 1. Hvad er DNS — og hvorfor har vi det? (2 min)

### Domænenavne vs IP-adresser

- **Problem:** Mennesker husker navne (ek.dk), computere bruger IP-adresser (77.66.89.180)
- **DNS (Domain Name System):** Oversætter domænenavne til IP-adresser — "internettets telefonbog"
- Distribueret, hierarkisk system — ingen enkelt server har hele kortet

> **Sig:** "DNS oversætter et domænenavn som `ek.dk` til den IP-adresse, din browser skal bruge for at oprette forbindelse. Uden DNS skulle du huske IP-adresser på alle de sider, du besøger."

### Hvem bestemmer hvilken IP-adresse et domæne peger på?

- **Domæneejet (registranten)** bestemmer — via deres DNS-udbyder/hosting
- Opsættes som DNS-records på den **autoritative navneserver** for domænet
- Eksempel: `ek.dk` ejes af JP/Politikens Hus — de styrer hvilken IP der svares med

---

## 2. DNS-recordtyper og TTL (2 min)

### Vigtige DNS-recordtyper

| Record-type | Formål | Eksempel |
|-------------|--------|----------|
| **A** | IPv4-adresse for et domæne | `ek.dk. 300 IN A 77.66.89.180` |
| **AAAA** | IPv6-adresse for et domæne | `ek.dk. 300 IN AAAA 2a00:1a28:...` |
| **CNAME** | Alias — peger på et andet domænenavn | `www.ek.dk. IN CNAME ek.dk.` |
| **MX** | Mailserver for domænet | `ek.dk. IN MX 10 mail.ek.dk.` |
| **NS** | Autoritativ navneserver for domænet | `ek.dk. IN NS ns1.ek.dk.` |
| **TXT** | Tekstdata — validering, SPF, DKIM | `ek.dk. IN TXT "v=spf1 include:..."` |

> **Pointer:** A og AAAA er de mest almindelige — de oversætter navn til IP. CNAME lader dig pege flere navne samme sted.

### TTL (Time-To-Live)

- **Hvad:** Hvor længe (i sekunder) en DNS-resolver må cache et svar
- **Høj TTL (dag/uge):** Mindre load på DNS-servere, hurtigere opslag — men langsom ændringspropagering
- **Lav TTL (minutter):** Hurtig ændring — bruges ved migration, load balancing, disaster recovery
- Typisk: `300` (5 min) til `86400` (24 timer)

> **Sig:** "Hvis TTL er 86400 og du ændrer IP-adressen, vil nogle brugere stadig få den gamle IP i op til 24 timer. Derfor sænker man TTL før en migration."

---

## 3. Autoritative navneservere vs cachende resolvere (2 min)

### Autoritativ navneserver

- **Kilden til sandhed** for et domæne
- Svarer med de officielle DNS-records
- Eksempel: `ns1.ek.dk` — JP/Politikens egen navneserver

### Cachende navneserver (recursive resolver)

- Modtager forespørgsler fra klienter og slår op **rekursivt**
- Cacher svaret i TTL-perioden — genbruger ved næste forespørgsel
- Eksempler: ISP's DNS (`8.8.8.8` — Google), `1.1.1.1` — Cloudflare

### Rekursivt opslag — trin for trin

```text
Browser spørger: "Hvad er IP'en for ek.dk?"
  1. Klient → Cachende resolver (fx 8.8.8.8)
  2. Resolver → Root-nameserver (.). "Hvem har .dk?"
  3. Root → .dk TLD-nameserver. "Hvem har ek.dk?"
  4. .dk → Autoritativ for ek.dk. "IP = 77.66.89.180"
  5. Svar går retur: 77.66.89.180 — cachelokalt i resolver
```

> **Sig:** "Den rekursive resolver gør det tunge arbejde. Den starter ved roden, går til TLD (.dk), og ender hos den autoritative server — alt sammen på millisekunder."

---

## 4. HTTP — protokollen på appliceringslaget (2,5 min)

### HTTP-anmodning: GET vs POST

| Metode | Formål | Kropsindhold | Idempotent |
|--------|--------|-------------|------------|
| **GET** | Hente data (læs) | Nej | Ja — samme request giver samme resultat |
| **POST** | Sende data (opret/ændr) | Ja — form-data, JSON | Nej — flere POST kan have bivirkninger |

> **Sig:** "GET bruges til at hente en side eller et API-kald. POST bruges når du sender noget nyt — fx ved oprettelse af en bruger."

### HTTP-statuskoder — de vigtigste grupper

| Klasse | Betydning | Eksempler |
|--------|-----------|-----------|
| **2xx** | Succes | `200 OK`, `201 Created`, `204 No Content` |
| **3xx** | Omdirigering | `301 Moved Permanently`, `302 Found`, `304 Not Modified` |
| **4xx** | Klientfejl | `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found` |
| **5xx** | Serverfejl | `500 Internal Server Error`, `502 Bad Gateway`, `503 Service Unavailable` |

> **Demonstration (kort):** Åbn DevTools Network-fanen, besøg en side, peg på en 200-response og evt. en 301/redirect eller 404.

### HTTP-headere: Accept vs Content-Type

- **`Accept` (request):** Fortæller serveren hvilke dataformater klienten forstår
  - `Accept: text/html`, `Accept: application/json`, `Accept: */*`
- **`Content-Type` (response/request):** Fortæller modtageren hvilket format data er i
  - `Content-Type: text/html; charset=utf-8`, `Content-Type: application/json`

> **Sig:** "Accept er hvad klienten *vil have*. Content-Type er hvad data *faktisk er*."

---

## 5. HTTP som tilstandsløs protokol — hvordan forbliver man logget ind? (1,5 min)

- **HTTP er stateless:** Hver request er uafhængig — serveren husker ikke tidligere requests
- **Løsning:** Sessioner og cookies
  1. Server sender en `Set-Cookie`-header ved login (indeholder session-ID)
  2. Browseren gemmer cookien og sender den med hver efterfølgende request (`Cookie:`-header)
  3. Serveren slår session-ID op og genkender brugeren

```text
Request 1 (login):  POST /login → Set-Cookie: sessionId=abc123
Request 2 (profil): GET /profile → Cookie: sessionId=abc123 → Server genkender dig
```

- Alternativ moderne tilgang: **JWT (JSON Web Tokens)** — token i Authorization-header

> **Sig:** "Cookies er limen der gør HTTP's tilstandsløshed brugbar. Uden dem skulle du logge ind ved hvert sideklik."

---

## 6. Live demonstration (3,5 min)

### Forberedt på computeren — terminal og browser klar

#### 1. DNS-opslag med `nslookup` og `dig` (1 min)

```bash
nslookup ek.dk
# Server:  dns.google
# Address:  8.8.8.8
# Name:    ek.dk
# Address:  77.66.89.180

nslookup -type=MX ek.dk        # Se MX-records
nslookup -type=NS ek.dk        # Se navneservere
```

```bash
dig ek.dk                      # Mere detaljeret output
dig ek.dk ANY                  # Alle recordtyper
dig ek.dk +short               # Kun IP-adressen
```

> Peg på: spørgsmål-sektionen, svars-sektionen, TTL, authoritative-svar vs ikke.

#### 2. DevTools Network-fanen (1 min)

1. Åbn DevTools (F12) → Netværksfanen
2. Besøg `https://ek.dk`
3. Peg på:
   - **Request:** GET / HTTP/1.1, headers (Accept, User-Agent, Cookie)
   - **Response:** Statuskode (200), headers (Content-Type, Set-Cookie)
   - **Timing:** DNS-opslag, TCP-forbindelse, TLS-handshake, ventetid, download

> **Sig:** "Alle dele af rejsen kan ses her — fra DNS-opslag til sidste byte. Fanen er dit bedste debug-værktøj som webudvikler."

#### 3. WireShark — HTTP GET (1,5 min)

1. Start WireShark → filter: `tcp.port == 80` (eller `tcp.port == 443`)
2. Kør `curl http://example.com` (eller mod egen VM)
3. Find HTTP GET-requesten:
   - **Request:** `GET / HTTP/1.1`, `Host: example.com`, `User-Agent: curl/...`
   - **Response:** `HTTP/1.1 200 OK`, `Content-Type: text/html`, body
4. Peg på: klartekst — man kan læse alt (derfor er HTTPS vigtigt)

> **Sig:** "I HTTP kan du læse forespørgslen og svaret i klartekst. Det er derfor HTTPS og TLS er nødvendige for sikkerhed."

---

## 7. Afrunding (1 min)

- **DNS** oversætter domænenavne til IP-adresser — distribueret, hierarkisk system
  - A/AAAA/CNAME/MX — recordtyper
  - TTL styrer cachetid
  - Autoritativ server vs rekursiv resolver
- **HTTP** er appliceringsprotokollen på internettet
  - GET vs POST, statuskoder (2xx–5xx)
  - Headere: Accept og Content-Type
  - Stateless — sessions opretholdes via cookies/JWT
- **Værktøjer:** `nslookup`/`dig` til DNS, DevTools til HTTP-debug, WireShark til trafik-inspektion
- **Rød tråd:** Når du skriver `https://ek.dk` i browseren → DNS slår IP'en op → TCP forbinder → HTTP-anmodning sendes → svar returneres

---

## Forberedte eksempler på computeren

| # | Demonstration | Fil / sted |
|---|---------------|------------|
| 1 | Simpelt DNS-opslag med `nslookup` på ek.dk | Terminal åben |
| 2 | Avanceret DNS-opslag med `dig` — vis TTL, recordtyper | Terminal |
| 3 | DevTools Netværksfane — request, response, headers | Browser med DevTools |
| 4 | WireShark — HTTP GET-request og response i klartekst | WireShark + `curl http://example.com` |

---

## Forventede opfølgende spørgsmål fra eksaminator

- *Hvem bestemmer hvilken IP-adresse et domæne peger på?*
- *Hvilke slags DNS-recordtyper findes der?*
- *Hvad er TTL for en DNS-record, og hvorfor sætter man den højt eller lavt?*
- *Hvad er forskellen på en autoritativ navneserver og en cachende navneserver?*
- *Hvordan fungerer en rekursiv resolver?*
- *Hvornår bruger man hhv. GET og POST?*
- *Hvilke HTTP-statuskoder findes der? — 2xx, 3xx, 4xx, 5xx?*
- *Hvad er forskellen på HTTP-headerne Accept og Content-Type?*
- *Hvis HTTP er en tilstandsløs protokol, hvordan forbliver man logget ind på en hjemmeside?*
