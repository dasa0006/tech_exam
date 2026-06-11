# Disposition: Kryptering og sikkerhed

**Varighed:** 15 minutter
**Formål:** Forklare fundamentale krypteringskoncepter, TLS/HTTPS, og SSH-tunnels med praktiske demonstrationer.

---

## Del 1 — Introduktion (1 minut)

- Kort overblik over emnet: Kryptering er fundamentet for al sikker kommunikation på nettet.
- Tre hovedområder i dispositionen:
  1. Krypteringsprincipper (symmetrisk, asymmetrisk, hashing)
  2. TLS/HTTPS og certifikater
  3. SSH, tunnels og VPN

---

## Del 2 — Krypteringsprincipper (3 minutter)

### Symmetrisk vs. asymmetrisk kryptering
- **Symmetrisk:** Samme nøgle til kryptering og dekryptering (fx AES). Hurtig, men nøgleudveksling er et problem.
- **Asymmetrisk:** Offentlig/privat nøglepar (fx RSA, Ed25519). Langsom, men løser nøgleudveksling.
- **Typisk brug:** Asymmetrisk til at udveksle en session-nøgle, herefter symmetrisk til selve data.

### Hash-funktioner vs. kryptering
- Hash er envejs: samme input → samme hash, kan ikke reverseres.
- Kryptering er tovejs: kan fortrydes med den rigtige nøgle.
- Anvendelse: hashing til passwords og integritetstjek.

### Digital signatur
- Hash af data krypteres med afsenderens private nøgle.
- Modtageren verificerer med afsenderens offentlige nøgle.
- Sikrer: autenticitet, integritet, non-repudiation.

### GPG (GNU Privacy Guard)
- Implementering af OpenPGP-standarden.
- Anvendelse: signere commits, kryptere filer, verificere identitet.

---

## Del 3 — TLS/HTTPS og certifikater (4 minutter)

### TLS handshake
1. **ClientHello** — browseren sender understøttede cipher suites + TLS-version
2. **ServerHello** — serveren vælger cipher suite + sender sit certifikat
3. **Certificate** — serverens certifikat indeholder offentlig nøgle + identitet
4. **Nøgleudveksling** — klient genererer pre-master secret, krypterer med serverens offentlige nøgle
5. **Færdig** — begge parter udleder session-nøgler → krypteret kommunikation

> **Demonstration 1:** `openssl s_client -connect ek.dk:443` og `openssl x509 -text`  
> Vis certifikatets udsteder, emne, gyldighedsperiode og offentlige nøgle.

### Certifikatkæde og Certificate Authority (CA)
- Certifikatet er signeret af en CA (fx Let's Encrypt).
- **Certifikatkæde:** Leaf-certifikat → Intermediate CA → Root CA (selvsigneret i OS'enes trust store).
- Browseren stoler på Let's Encrypt, fordi den har en kopi af Let's Encrypts Root CA-certifikat i sin **trust store** (forudinstalleret af OS).

> **Demonstration 2:** Wireshark — TLS handshake  
> Fang en `curl` til ek.dk:443. Peg på ClientHello, ServerHello, Certificate-pakkerne.

### Hvorfor HTTP er synligt i Wireshark, men ikke HTTPS
- HTTP: al trafik i klartekst → Wireshark viser hele request/response.
- HTTPS: al data er krypteret efter TLS handshake → Wireshark ser kun krypterede `Application Data`-pakker.

---

## Del 4 — SSH, tunnels og VPN (4 minutter)

### SSH public key authentication
- Bruger asymmetrisk kryptering (typisk Ed25519 eller RSA).
- **`id_ed25519`** = privat nøgle, må aldrig deles. Opbevares sikkert.
- **`id_ed25519.pub`** = offentlig nøgle, må deles frit. Lægges på serverens `~/.ssh/authorized_keys`.
- **Forløb:** Klient beviser identitet ved at signere en challenge med sin private nøgle — serveren verificerer med den offentlige nøgle.

> **Demonstration 3:** Generer SSH nøglepar med `ssh-keygen -t ed25519`  
> Vis forskellen på `id_ed25519` (privat) og `id_ed25519.pub` (offentlig) — `cat` af begge.

### SSH tunnel (port forwarding)
- Krypteret tunnel gennem en SSH-forbindelse.
- Eksempel: `ssh -L 8080:localhost:80 user@vm`
  - Lokal port 8080 → SSH tunnel → vm's localhost:80
- Nyttigt til: adgang til interne tjenester gennem en bastion-host, kryptering af ellers ukrypterede protokoller.

> **Demonstration 4:** Sæt en SSH tunnel op med `ssh -L`  
> Forklar at al trafik mellem lokal maskine og VM er krypteret via SSH-protokollen.

### VPN (WireGuard) vs. SSH tunnel
- **SSH tunnel:** applikationsspecifik port forwarding (enkelt porte/protokoller).
- **VPN (WireGuard):** krypterer alt netværkstrafik på IP-niveau. Opretter et virtuelt netværksinterface.
- WireGuard er hurtigere, enklere og kører i kernel space.
- Begge giver krypteret tunneler, men på forskellige lag i netværksmodellen.

---

## Del 5 — Afrunding (2 minutter)

### Oversigt over demonstrationer
| Demo | Kommando / Værktøj | Formål |
|------|-------------------|--------|
| 1 | `openssl s_client -connect ek.dk:443` | Inspicer TLS-certifikat |
| 2 | Wireshark | Visualisér TLS handshake |
| 3 | `ssh-keygen -t ed25519` | Forstå public/private keypar |
| 4 | `ssh -L 8080:localhost:80` | Krypteret tunnel |

### Sammenklip — nøglepointer
1. Symmetrisk kryptering = hurtig, asymmetrisk = sikker nøgleudveksling — brug begge (hybrid).
2. TLS sikrer HTTPS via certifikater og en CA-tillidsmodel.
3. SSH-tunnels og VPN krypterer trafik på forskellige netværkslag.
4. Wireshark er et stærkt værktøj til at visualisere både ukrypteret og krypteret trafik.

### Mulige opfølgende spørgsmål fra eksaminator
- Forklar forskellen på hash og kryptering igen.
- Hvad er en certifikatkæde, og hvordan etableres tillid?
- Hvordan håndterer man nøgler sikkert?
- Hvordan påvirker port forwarding sikkerhed?
- Hvordan adskiller WireGuard sig fra OpenVPN/SSH?
