### Teoretiske spørgsmål

**1. Netværkslag i TCP/IP- og OSI-modellen**  
**OSI-modellen** har 7 lag (oppefra og ned):  
7. Applikation – 6. Præsentation – 5. Session – 4. Transport – 3. Netværk – 2. Data Link – 1. Fysisk  

**TCP/IP-modellen** har 4 lag, der dækker OSI’s funktionalitet:  
4. Applikation (OSI 5+6+7) – 3. Transport (OSI 4) – 2. Internet (OSI 3) – 1. Network Access (OSI 1+2)  
Nogle anvender en 5-lags variant (App, Transport, Netværk, Data Link, Fysisk) for at matche undervisning.

**2. IP-adresse vs. MAC-adresse**  
- **MAC-adresse** (Media Access Control): 48-bit hardwareadresse, der identificerer et netværksinterface på lag 2 (Data Link). Den er ”brændt ind” i hardwaren og ændres normalt ikke. Bruges til kommunikation inden for samme netværkssegment (f.eks. dit lokale LAN). Format: `aa:bb:cc:dd:ee:ff`.  
- **IP-adresse** (Internet Protocol): 32-bit (IPv4) eller 128-bit (IPv6) logisk adresse på lag 3 (Netværk). Den tildeles enten manuelt eller dynamisk (f.eks. via DHCP) og bruges til routing mellem netværk. Offentlige IP-adresser er globalt unikke; private IP-adresser genbruges i lokale net.

**3. Hvorfor kan jeg ikke aflæse ek.dk’s MAC-adresse i Wireshark?**  
MAC-adresser er kun synlige inden for det lokale netværkssegment. Når du kommunikerer med en server på internettet (som ek.dk), sender din computer pakkerne til din **default gateway** (routeren). Pakken indeholder derfor routerens MAC-adresse som destinations-MAC. Serverens MAC-adresse optræder aldrig i dine pakker, fordi MAC-adresser strippes og erstattes ved hvert hop gennem routere. Wireshark fanger kun det, der ankommer på din netværksinterface – altså din egen MAC og gatewayens MAC.

**4. Router vs. switch – funktioner og forskelle**  
| Funktion | Router | Switch |
|----------|--------|--------|
| **OSI-lag** | Lag 3 (Netværk) | Lag 2 (Data Link) |
| **Videresender ud fra** | IP-adresser | MAC-adresser |
| **Formål** | Forbinder forskellige netværk (WAN/LAN) og ruter mellem dem | Forbinder enheder inden for **samme** netværk |
| **Broadcast-domæne** | Opdeler broadcast-domæner (stopper broadcast) | Som udgangspunkt ét broadcast-domæne (medmindre VLAN bruges) |
| **Typiske funktioner** | NAT, firewall, DHCP-server, QoS, VPN | MAC-adressetabel, VLAN, link aggregation, port security |

En hjemme-”router” indeholder typisk en router, en switch og et trådløst access point i én boks.

---

### Praktiske spørgsmål

**5. Forskel på lokalnet-adresse og offentlig adresse**  
- **Lokalnet-adresse** (privat IP): tilhører det private IP-område (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`). Bruges inden for dit hjem/ LAN og routes ikke på det offentlige internet.  
- **Offentlig adresse** (public IP): globalt unik, tildelt af din internetudbyder. Det er den adresse, som servere på internettet ser, når du laver forespørgsler. Routeren oversætter via **NAT** (Network Address Translation) mellem din private IP og den offentlige IP.

**6. Filtrering i Wireshark til en specifik hjemmeside eller protokol**  
Brug **display filter** (nederst i vinduet) eller **capture filter** (før start):  
- Til hjemmesiden `ek.dk`: Hvis du kender IP’en (fx via `nslookup`), brug `ip.addr == <IP>` – f.eks. `ip.addr == 93.184.216.34`.  
  Eller filtrer på HTTP-værtsnavn: `http.host == "ek.dk"` (virkede kun for ukrypteret HTTP; for HTTPS brug `tls.handshake.extensions_server_name == "ek.dk"`).  
- Til protokol: `tcp`, `udp`, `dhcp` (virkelig `bootp`), `dns`, `http`, `icmp`. Skriv bare protokolnavnet.  
- **Capture filter**-eksempel: `host ek.dk` (kræver DNS-opslag), `port 80`, `tcp port 443`.

**7. Hvad er en port, og hvorfor har man porte?**  
En port er et 16-bit nummer (0–65535), der identificerer en specifik proces eller tjeneste på en vært. Transportlaget (TCP/UDP) bruger porte til at levere data til det rigtige program. Kombinationen af IP + port giver en entydig endpoint.  
**Standardporte (eksempler):**  
HTTP: 80, HTTPS: 443, DNS: 53, SSH: 22, SMTP: 25, DHCP (server): 67, DHCP (klient): 68, FTP: 21.

**8. `src` og `dst` for en IP-pakke**  
I IP-headeren:  
- `src` (source): Afsenderens IP-adresse (kilde).  
- `dst` (destination): Modtagerens IP-adresse (mål).  
Disse er lag 3-adresser og ændres typisk ikke undervejs (med mindre NAT involveret).

**9. `src port` og `dst port` for en TCP-pakke**  
I TCP- (eller UDP-) headeren:  
- `src port`: Afsenderens portnummer (oftest en tilfældig, høj port hos klienten, f.eks. 54321).  
- `dst port`: Modtagerens portnummer (oftest en standardport, f.eks. 80 for HTTP).  
De angiver hvilken applikation, der taler med hvilken.

**10. SYN, ACK og FIN – hvordan ses de i Wireshark?**  
Disse er **kontrolflag** i TCP-headeren:  
- **SYN**: Bruges til at starte en forbindelse (synkronisering af sekvensnumre).  
- **ACK**: Bruges til at bekræfte modtagelse af data eller kontrolsegmenter.  
- **FIN**: Bruges til at afslutte en forbindelse elegant (”no more data from sender”).  
I Wireshark vises de under `Transmission Control Protocol` i detaljeruden, med felterne `Flags: ...`. Man ser f.eks. `[SYN]`, `[SYN, ACK]`, `[ACK]`, `[FIN, ACK]`. I pakkelisten viser kolonnen ”Info” ofte flagene direkte.

**11. Forskel på TCP og UDP**  
| Egenskab | TCP | UDP |
|----------|-----|-----|
| Forbindelse | Forbindelsesorienteret (kræver handshake) | Forbindelsesløs |
| Pålidelighed | Pålidelig – levering og rækkefølge garanteres | Upålidelig – ingen garanti for levering |
| Flowkontrol / mætningskontrol | Ja, via vinduesmekanisme | Ingen |
| Hastighed / overhead | Mere overhead (større header, acknowledgement) | Mindre overhead, hurtigere |
| Anvendelse | Web, email, filoverførsel (HTTP, SMTP, FTP) | Streaming, VoIP, DNS, DHCP, online gaming |

**12. Sequence Number og Acknowledgment Number**  
- **Sequence Number** (sekvensnummer): Angiver positionen for det første databyte i dette segment i forhold til datastrømmen.  
- **Acknowledgment Number** (anerkendelsesnummer): Indeholder det næste sekvensnummer, som afsenderen af denne pakke forventer at modtage – dvs. alt data op til dette nummer er modtaget korrekt.  
**Wireshark-eksempel:** Efter et SYN (seq=0 relativ) svarer serveren med SYN, ACK (seq=0, ack=1), og klienten sender ACK (seq=1, ack=1). Senere data-ACK: Klient sender HTTP GET (seq=1, len=100), serverens ACK har ack=101. I Wireshark vises ”Sequence Number (raw)” og ”Acknowledgment Number (raw)” samt relative værdier i parentes.

---

### Demonstration

**1. Illustration af TCP/IP- og OSI-modellen**  
Jeg kan ikke tegne her, men beskriv gerne en lagdelt figur:  
- Øverst Applikationslaget (HTTP, DNS, DHCP) – svarer til OSI 5‑7.  
- Transportlaget (TCP, UDP) – OSI 4.  
- Internetlaget (IP, ICMP) – OSI 3.  
- Netværksadgangslaget (Ethernet, Wi-Fi) – OSI 1‑2.  
Hvert lag indkapsler data fra laget over, og tilføjer sin egen header (og evt. trailer). Med OSI kan man indsætte de to ekstra lag mellem applikation og transport.

**2. Find din lokalnet- og offentlige IP-adresse**  
- **Lokal (privat) IP:**  
  Windows: `ipconfig` → se ”IPv4 Address” under dit netværkskort.  
  Linux/macOS: `ifconfig` eller `ip addr show` → se `inet`-adressen (ofte 192.168.x.x eller 10.x.x.x).  
- **Offentlig IP:** Besøg en tjeneste som `https://ifconfig.me` i en browser, eller kør `curl ifconfig.me` i terminalen. Du kan også se den i routerens administrationsside under WAN-status.

**3. Forklar output fra `nslookup ek.dk` og `ping ek.dk`**  
- `nslookup ek.dk` viser DNS-opslag:  
  Server: din DNS-server  
  Address: <dns-ip>  
  Non-authoritative answer:  
  Name: ek.dk  
  Address: <ip-adresse, fx 93.184.216.34>  
  Det fortæller, at domænet `ek.dk` oversættes til den angivne IP.  
- `ping ek.dk` sender ICMP Echo Requests:  
  Pinging ek.dk [ip-adresse] with 32 bytes of data:  
  Reply from ip: bytes=32 time=15ms TTL=55  
  TTL (Time To Live) viser antal hop tilbage; tid er latency. Hvis serveren blokerer ICMP, får du ”Request timed out”. Da det ikke altid svarer, kan du alternativt bruge `curl` eller Telnet til at teste TCP-forbindelse.

**4. I Wireshark: filtrer til kun trafik til/fra en hjemmeside**  
1. Find IP’en for sitet (fx `nslookup ek.dk`).  
2. Start Wireshark capture på det aktive interface.  
3. I display filterfeltet øverst skriv: `ip.addr == 93.184.216.34`. (IP’en du fandt).  
4. Evt. tilføj `and http` eller `and tcp.port == 443` for at begrænse yderligere.  
Hvis du kun vil fange HTTP-forespørgsler, kan du under optagelse bruge capture filter: `host ek.dk`.

**5. Wireshark: Vis hvordan man får tildelt en IP-adresse med DHCP**  
DHCP-processen hedder **DORA** (Discover, Offer, Request, Acknowledge).  
- Åbn Wireshark og sæt et display filter til `bootp` (BOOTP = DHCP).  
- Slip din nuværende IP: `ipconfig /release` (Windows) eller `dhclient -r` (Linux).  
- Forny: `ipconfig /renew` eller `dhclient`.  
- Du ser fire pakker:  
  1. **DHCP Discover** – klienten sender broadcast for at finde DHCP-server.  
  2. **DHCP Offer** – server tilbyder en IP.  
  3. **DHCP Request** – klienten anmoder om den tilbudte IP.  
  4. **DHCP ACK** – server bekræfter tildelingen.  
I kolonnen Info ses `DHCP Discover`, `DHCP Offer`, osv., og detaljerne indeholder den tilbudte IP, lease-tid, DNS-servere m.m.

**6. Vis TCP-handshake i Wireshark ved at `curl`’e en hjemmeside**  
Åbn Wireshark og sæt capture filter: `tcp port 80` (hvis VM kører HTTP) eller `tcp port 443` for HTTPS. Kør f.eks. `curl http://<VM-ip>` i terminalen.  
- Find de tre handshake-pakker:  
  1. **SYN**: `Client → Server` flag `[SYN]` (seq=0 relativ).  
  2. **SYN, ACK**: `Server → Client` flag `[SYN, ACK]` (seq=0, ack=1).  
  3. **ACK**: `Client → Server` flag `[ACK]` (seq=1, ack=1).  
I Wireshark kan du højreklikke på den første pakke og vælge ”Follow → TCP Stream” for at se hele dialogen inklusiv HTTP-request/response.

**7. Vis TCP teardown i Wireshark**  
Efter dataudvekslingen afsluttes forbindelsen med FIN-pakker. Typisk session:  
- En af parterne (ofte serveren) sender en TCP-pakke med **FIN** flag, hvilket signalerer at den ikke har mere data.  
- Modparten kvitterer med **ACK**, og sender derefter sit eget **FIN**.  
- Den første part kvitterer med **ACK**.  
I Wireshark kan du filtrere på `tcp.flags.fin == 1` for at isolere FIN-pakkerne.  
Gør sådan her: Start capture, lav `curl http://<VM-ip>/some-page` og se afslutningen. Alternativt kan du åbne en Telnet-session til en port, skrive noget og lukke – Wireshark vil vise FIN/ACK-sekvensen. I pakkelisten ser du f.eks.:  
  1. `[FIN, ACK]` (server → klient)  
  2. `[ACK]` (klient → server)  
  3. `[FIN, ACK]` (klient → server)  
  4. `[ACK]` (server → klient)  

Bemærk, at nogle implementationer kan sende et enkelt `[FIN, ACK]` og modtage et `[ACK]` (halvlukning), men det fulde teardown er typisk to FIN’er.
