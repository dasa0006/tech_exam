# TCP/IP — Eksamensdisposition

**Varighed:** 15 minutter
**Formål:** Forklare TCP/IP-modellens lag, centrale netværkskoncepter og demonstrere WireShark-færdigheder

---

## 1. TCP/IP- og OSI-modellen — oversigt (2 min)

### Lagene i TCP/IP vs OSI

| OSI-model (7 lag) | TCP/IP-model (4 lag) | Eksempler |
|-------------------|---------------------|-----------|
| Application | Application | HTTP, DNS, DHCP |
| Presentation | (smeltet ind i Application) | TLS/SSL |
| Session | (smeltet ind i Application) | — |
| Transport | Transport | TCP, UDP |
| Network | Internet | IP, ICMP |
| Data Link | Network Access | Ethernet, MAC |
| Physical | (indgår i Network Access) | Kabel, signal |

> **Sig:** "TCP/IP er den praktiske model, internettet er bygget på. OSI er den teoretiske referencemodel med 7 lag. Vi bruger primært TCP/IP-modellen."

### Illustration af datastrøm

```text
[Browser] ──HTTP──▶ [TCP] ──segment──▶ [IP] ──pakke──▶ [Ethernet] ──frame──▶ [Kabel]
```

> **Demonstration:** Vis en illustration af modellen (kan være tegnet på whiteboard eller en figur på skærmen). Peg på hvert lag og forklar kort.

---

## 2. IP-adresser, MAC-adresser, router vs switch (2,5 min)

### IP-adresse vs MAC-adresse

| | IP-adresse | MAC-adresse |
|--------------|------------|-------------|
| **Lag** | Internet-lag (3) | Network Access-lag (2) |
| **Formål** | Logisk adresse — finder enheden på tværs af netværk | Fysisk adresse — finder enheden på samme lokalnet |
| **Eksempel** | `192.168.1.10` eller `87.49.22.184` | `00:1A:2B:3C:4D:5E` |
| **Ændres?** | Ja — skifter når enheden flytter mellem netværk | Nej — indbrændt i netværkskortet (kan spoofes) |

> **Sig:** "IP-adressen er som husadressen på et brev. MAC-adressen er som CPR-nummeret på modtageren — den følger enheden."

### Hvorfor kan jeg ikke se ek.dk's MAC-adresse i WireShark?

- MAC-adresser bruges kun inden for **samme lokalnet** (Ethernet-switch)
- Når en pakke forlader dit lokalnet, erstatter routeren MAC-adresserne undervejs (hop-for-hop)
- I WireShark ser du kun MAC-adressen på **næste hop** (din router), ikke afsender/modtager på tværs af internettet

### Router vs Switch

| Funktion | Router | Switch |
|----------|--------|--------|
| **Lag** | Internet-lag (3) — IP | Network Access-lag (2) — MAC |
| **Formål** | Viderestiller pakker mellem **forskellige** netværk | Viderestiller frames inden for **samme** lokalnet |
| **Adressering** | IP-adresse | MAC-adresse |
| **Eksempel** | Internet-router i hjemmet | Netværksswitch i serverrum |

> **Sig:** "Switchen kender MAC-adresserne på sit lokalnet. Routeren kender ruter til andre netværk."

---

## 3. Lokalnet vs public IP, nslookup og ping (2 min)

### Lokalnet-adresse vs public adresse

- **Lokal IP (privat):** `10.x.x.x`, `172.16-31.x.x`, `192.168.x.x` — kun gyldig i eget netværk
- **Public IP:** Globalt unik — tildelt af ISP, synlig på internettet
- **NAT (Network Address Translation):** Routeren oversætter privat → public og omvendt

> **Demonstration:** Find din lokalnet IP (`ipconfig` / `ip a`) og din offentlige IP (`curl ifconfig.me` eller browser på "what is my ip").

### nslookup og ping

```bash
nslookup ek.dk
# Svar: Server:  dns.google
#        Address:  8.8.8.8
#        Name:     ek.dk
#        Address:  77.66.89.180
```

- **`nslookup`:** Spørger en DNS-server — "hvad er IP'en for dette domæne?"
- **`ping`:** Sender ICMP Echo Request — "er maskinen tilgængelig?" og viser round-trip time

> **Demonstration:** Kør `nslookup ek.dk` og `ping ek.dk` og forklar outputtet — IP-adressen, TTL, svar-tider.

---

## 4. Porte, TCP vs UDP, src/dst (2,5 min)

### Hvad er en port?

- **Port:** Et 16-bit nummer (0-65535) der identificerer en **specifik proces/service** på en maskine
- **Hvorfor:** Én IP-adresse kan have mange tjenester kørende (webserver, mail, SSH)

### Standardporte (eksempler)

| Port | Protokol | Tjeneste |
|------|----------|----------|
| 20/21 | TCP | FTP |
| 22 | TCP | SSH |
| 25 | TCP | SMTP (mail) |
| 53 | TCP/UDP | DNS |
| 80 | TCP | HTTP |
| 443 | TCP | HTTPS |
| 3306 | TCP | MySQL |
| 5432 | TCP | PostgreSQL |

### src og dst for IP- og TCP-pakker

- **IP-pakke:** `src IP` = afsender, `dst IP` = modtager
- **TCP-segment:** `src port` = afsender-proces, `dst port` = modtager-proces

> **Sig:** "IP-adresserne finder maskinerne. Portene finder processerne på maskinerne."

```text
Eksempel: Din browser (port 54321) → ek.dk's webserver (port 443)
           IP src: 192.168.1.10    IP dst: 77.66.89.180
           TCP src port: 54321     TCP dst port: 443
```

### TCP vs UDP

| Egenskab | TCP | UDP |
|----------|-----|-----|
| **Forbindelse** | Forbindelsesorienteret (handshake) | Forbindelsesløs |
| **Pålidelighed** | Bekræftelse, genforsendelse | Ingen garanti |
| **Rækkefølge** | Bevarer rækkefølge (SEQ/ACK) | Ingen garanti |
| **Hastighed** | Lavere (overhead) | Højere |
| **Bruges til** | Web (HTTP), mail, filoverførsel | Streaming, DNS, VoIP, gaming |

> **Sig:** "TCP er som et anbefalet brev — du får besked når det ankommer. UDP er som et postkort — hurtigt, men du ved ikke om det når frem."

---

## 5. TCP handshake, teardown, SEQ/ACK (2 min)

### TCP Three-Way Handshake

```text
CLIENT ──── SYN (seq=x) ──────────▶ SERVER    (Jeg vil gerne connecte)
CLIENT ◀─── SYN+ACK (seq=y, ack=x+1) ──── SERVER    (OK, jeg er klar)
CLIENT ──── ACK (seq=x+1, ack=y+1) ──────▶ SERVER    (Forbindelse etableret)
```

- **SYN:** Anmodning om forbindelse
- **ACK:** Bekræftelse af modtagelse
- **FIN:** Anmodning om at afslutte forbindelse (teardown)

### Sequence Number og Acknowledgment Number

- **Sequence Number:** Hvert segments plads i datastrømmen — sikrer korrekt rækkefølge
- **Acknowledgment Number:** Næste forventede byte — "jeg har modtaget alt op til denne position"

> **Demonstration:** I WireShark:
> 1. `curl` en hjemmeside (fx egen VM eller `ek.dk`)
> 2. Filter: `tcp.port == 443`
> 3. Peg på de tre handshake-pakker: SYN → SYN+ACK → ACK
> 4. Vis Sequence/ACK numbers i pakkedetaljerne
> 5. Vis TCP teardown: FIN → ACK → FIN → ACK

---

## 6. Live demonstration (3 min)

### WireShark — filtrering og analyse

**Forberedt på computeren — WireShark åbent og klar:**

1. **Filtrering:**
   - `tcp` — kun TCP-trafik
   - `udp` — kun UDP-trafik
   - `dhcp` — kun DHCP-trafik
   - `ip.addr == 77.66.89.180` — trafik til/fra ek.dk
   - `tcp.port == 443` — kun HTTPS-trafik

2. **DHCP — tildeling af IP-adresse:**
   - Filter: `dhcp` eller `bootp`
   - Vis forløbet: Discover → Offer → Request → Ack (DORA)
   - Peg på: tildelt IP, subnet mask, gateway, DNS-server

3. **TCP handshake:**
   - Åbn terminal og kør `curl https://ek.dk` (eller mod egen VM)
   - Fangede pakker i WireShark med filter `tcp.port == 443`
   - Peg på SYN-, SYN+ACK- og ACK-pakkerne
   - Vis Sequence Number og Acknowledgment Number i pakkedetaljen

4. **TCP teardown:**
   - Efter curl-anmodningen — vis FIN-pakkerne
   - Forklar: FIN → ACK → FIN → ACK

> **Sig undervejs:** "Først ser vi handshake'et — tre pakker der etablerer forbindelsen. Bagefter kommer selve dataoverførslen. Til sidst lukkes forbindelsen med FIN-pakker."

---

## 7. Afrunding (1 min)

- **TCP/IP-modellen:** 4 lag — Application, Transport, Internet, Network Access
- **IP vs MAC:** Logisk vs fysisk adresse — routere arbejder på IP, switches på MAC
- **Porte:** Identificerer processer — src/dst port finder hvilke programmer der kommunikerer
- **TCP vs UDP:** Pålidelig forbindelse vs hurtig best-effort
- **TCP handshake:** SYN → SYN+ACK → ACK — fundamentet for pålidelig kommunikation
- **WireShark:** Uundværligt værktøj til at **se** netværkstrafik — filtrering, handshake, SEQ/ACK

---

## Forberedte eksempler på computeren

| # | Demonstration | Fil / sted |
|---|---------------|------------|
| 1 | TCP/IP-model illustration | Whiteboard-tegning eller billede på skærm |
| 2 | Find lokal IP (`ip a` / `ipconfig`) og public IP (`curl ifconfig.me`) | Terminal åben |
| 3 | `nslookup ek.dk` og `ping ek.dk` — forklar output | Terminal |
| 4 | WireShark — filtrering (trafik til ek.dk eller egen VM) | WireShark med capture |
| 5 | WireShark — DHCP DORA-forløb | WireShark med DHCP-filter |
| 6 | WireShark — TCP handshake (curl mod ek.dk eller egen VM) | Terminal + WireShark |
| 7 | WireShark — TCP teardown | Samme capture som handshake |

---

## Forventede opfølgende spørgsmål fra eksaminator

- *Hvilke netværkslag findes der i TCP/IP-modellen? — Hvad adskiller den fra OSI-modellen?*
- *Hvad er forskellen på en IP-adresse og en MAC-adresse?*
- *Hvorfor kan du ikke se ek.dk's MAC-adresse i WireShark?*
- *Hvad er forskellen på en router og en switch?*
- *Hvad er forskellen på din lokalnet-adresse og din public adresse? — Hvad er NAT?*
- *Hvordan filtrerer du i WireShark til en specifik IP eller protokol?*
- *Hvad betyder src og dst for henholdsvis IP og TCP?*
- *Hvad er SYN, ACK og FIN — og hvordan ser de ud i WireShark?*
- *Hvad er forskellen på TCP og UDP? — Hvornår bruger man hvilken?*
- *Hvad bruges Sequence Number og Acknowledgment Number til?*
