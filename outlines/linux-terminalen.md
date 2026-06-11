# Linux-terminalen — Eksamensdisposition

**Varighed:** 15 minutter
**Formål:** Forstå Linux-terminalens grundbegreber, shell-kommandoer, filsystem, piping/redirection, filrettigheder og remote adgang via SSH/SCP

---

## 1. Terminal vs Shell vs Kommando (2 min)

### De tre lag

| Begreb | Eksempel | Rolle |
|--------|----------|-------|
| **Terminal** | `cmd.exe`, gnome-terminal, iTerm2 | UI-programmet — giver et vindue til at skrive tekst |
| **Shell** | `bash`, `zsh`, `sh`, PowerShell | Tolk/fortolker — parser kommandoer, håndterer miljøvariabler |
| **Kommando** | `ls`, `pwd`, `grep` | Det eksekverbare program, der udfører et konkret stykke arbejde |

> **Sig:** "Terminalen er vinduet. Shell'en er motoren, der forstår hvad du skriver. Kommandoen er værktøjet, der gør arbejdet."

### Eksempel på samspillet

```text
Terminal:  [brugervindue]  →  (skriver "ls -l")
Shell:     bash læser teksten, parser argumentet "-l"
Kommando:  ls eksekveres med flaget "-l" → viser filer i langt format
Output:    vises tilbage i terminalen
```

> **Demonstration:** Åbn terminal, skriv `echo $0` for at se hvilken shell der kører. Kør `which ls` for at se hvor `ls` bor på disken.

---

## 2. SSH — Secure Shell (3 min)

### Hvad er SSH?

- **SSH (Secure Shell):** Krypteret protokol til at logge ind på eksterne servere
- Erstatning for telnet, rlogin — al trafik er krypteret
- Standardport: **22**
- Typisk brug: `ssh brugernavn@192.168.1.100` eller `ssh brugernavn@domæne.dk`

### Public key authentication — sådan virker det

```text
┌──────────────────────┐                    ┌──────────────────────┐
│    Lokal maskine     │                    │    Remote server     │
│                      │                    │                      │
│  ~/.ssh/id_ed25519   │                    │  ~/.ssh/authorized_keys
│  (PRIVAT — deles ALDRIG)                   │  (indeholder .pub)   │
│                      │                    │                      │
│  ~/.ssh/id_ed25519   │                    │                      │
│  .pub                 │                    │                      │
│  (OFFENTLIG — kan     │                    │                      │
│   deles)             │                    │                      │
└──────────────────────┘                    └──────────────────────┘
```

**Flow:**
1. Lokalt genereres et nøglepar: `ssh-keygen -t ed25519`
2. Offentlige nøgle kopieres til serveren: `ssh-copy-id bruger@server` (eller manuelt i `~/.ssh/authorized_keys`)
3. Ved login udfordrer serveren klienten med en tilfældig besked
4. Klienten signerer beskeden med **private** nøgle
5. Serveren verificerer signaturen med **public** nøgle → adgang gives

> **Sig:** "Den private nøgle beviser at du er den du påstår — uden at den nogensinde forlader din maskine."

### Forskellen på `id_ed25519` og `id_ed25519.pub`

| Fil | Synlighed | Må deles? |
|-----|-----------|-----------|
| `id_ed25519` | `-rw-------` (600) | **NEJ** — aldrig |
| `id_ed25519.pub` | `-rw-r--r--` (644) | Ja — lægges på servere |

> **Demonstration:** Generér nøglepar med `ssh-keygen -t ed25519`, vis begge filers indhold med `cat`, og forklar hvilken der må deles.

---

## 3. Live demonstration — Filsystem og navigation (2,5 min)

### Navigation

```bash
pwd                     # Hvor er jeg? (print working directory)
ls -la                  # Vis alle filer inkl. skjulte i langt format
cd /tmp                 # Skift til /tmp
mkdir -p projekt/src    # Opret mappestruktur (p = parent)
```

> **Demonstration:** Start i hjemmemappen, opret en mappestruktur `~/eksamen/linux-demo/`, navigér rundt med `pwd` og `cd`.

### Filhåndtering

```bash
touch fil.txt                       # Opret tom fil
echo "Hej verden" > fil.txt         # Skriv til fil
nano fil.txt                        # Rediger i terminal-baseret editor
cat fil.txt                         # Vis hele filen
head -n 3 fil.txt                   # Vis første 3 linjer
tail -n 5 fil.txt                   # Vis sidste 5 linjer
less fil.txt                        # Gennemse fil sidevis (q = quit)
```

> **Demonstration:** Opret en fil med `nano`, skriv nogle linjer tekst, afslut og vis indholdet med `cat`, `head`, `tail` og `less`.

### Søgning med grep

```bash
grep "fejl" logfil.txt                  # Find linjer med "fejl"
grep -i "warning" logfil.txt            # Case-insensitive søgning
grep -r "TODO" ~/projekt/               # Rekursiv søgning i mappe
grep -n "ERROR" app.log                 # Vis linjenumre
```

> **Sig:** "grep er din bedste ven til at finde noget i filer — uanset om det er logfiler, kildekode eller konfiguration."

---

## 4. Live demonstration — Piping og redirection (3 min)

### Output redirection — `>` og `>>`

```bash
ls -la > filoversigt.txt         # Skriv output til fil (OVERSKRIVER)
ls -la >> filoversigt.txt        # Tilføj output til fil (APPENDER)
```

> **Sig:** "`>` opretter eller overskriver. `>>` tilføjer til eksisterende indhold — sikrere når du ikke vil miste data."

### Undgå at overskrive — shell-indstillinger

```bash
set -o noclobber                # Forhindrer `>` i at overskrive eksisterende filer
ls -la > vigtig.txt             # Fejl: "cannot overwrite existing file"
ls -la >| vigtig.txt            # Tving overskrivning (override)
set +o noclobber                # Slå fra igen
```

> **Demonstration:** Opret en fil med vigtigt indhold. Forsøg at overskrive med `>` → fejl (hvis noclobber er slået til). Vis `>>` som det sikre alternativ.

### Piping — `|`

```bash
# Kæd kommandoer sammen — output fra én bliver input til næste
ls -la /usr/bin | head -20                      # De første 20 filer i /usr/bin
cat logfil.txt | grep "ERROR" | tail -10        # De sidste 10 ERROR-linjer
ps aux | grep java                              # Find Java-processer
```

> **Sig:** "Pipe tager output fra venstre kommando og sender det ind som input til højre kommando. Det er Unix-filosofien — små værktøjer der sammensættes."

### Kombiner det hele

```bash
# Eksempel: Find de 5 mest brugte shell-kommandoer i historikken
history | awk '{print $2}' | sort | uniq -c | sort -rn | head -5
```

```
  120 ls
   85 cd
   63 git
   42 nano
   38 cat
```

> **Demonstration:** Kør eksemplet ovenfor. Peg på hvert led i pipelinen og forklar hvad det gør.

---

## 5. Live demonstration — Filrettigheder og Remote adgang (3 min)

### Filrettigheder — `-rwxr--r--`

```text
Type  Ejer     Gruppe   Andre
 -    rwx      r--      r--
 │    │││      │││      │││
 │    ││└─ x   │└─ r    │└─ r
 │    │└── w   └── r    └── r
 │    └─── r
 └── fil (-) / mappe (d)
```

| Symbol | Betydning | Tal |
|--------|-----------|-----|
| `r` | read (læse) | 4 |
| `w` | write (skrive) | 2 |
| `x` | execute (udføre) | 1 |

```bash
chmod 755 script.sh          # Ejer: rwx, Gruppe: r-x, Andre: r-x
chmod u+x script.sh          # Tilføj execute til ejer
chmod go-w fil.txt           # Fjern skriverettighed for gruppe og andre
chmod -R 600 ~/.ssh/         # Rekursivt: kun ejer må læse SSH-nøgler
```

> **Demonstration:** Opret et script, vis `ls -l` output, forklar rettighederne, ændr med `chmod` og vis ændringen.

### SCP — Secure Copy (filoverførsel)

```bash
# Lokal → Remote
scp ./minfil.txt bruger@server:/home/bruger/

# Remote → Lokal
scp bruger@server:/home/bruger/fjernfil.txt .

# Rekursiv (hele mapper)
scp -r ./projekt/ bruger@server:/home/bruger/
```

> **Sig:** "SCP bruger samme SSH-forbindelse som dit login — al trafik er krypteret. Perfekt til at flytte filer sikkert mellem maskiner."

> **Demonstration:** Opret en fil lokalt, overfør til en remote server med `scp`, vis at den er ankommet ved at SSH'e ind og køre `ls -la`.

---

## 6. Afrunding (30 sek)

- **Terminal vs Shell vs Kommando:** Terminalen er vinduet, shell'en er tolken, kommandoen er værktøjet
- **SSH:** Krypteret remote adgang med public key authentication — privat nøgle deles aldrig
- **Filsystem:** `cd`, `ls`, `mkdir`, `touch`, `nano` — basis-navigation og filredigering
- **Indholdsvisning:** `cat`, `head`, `tail`, `less`, `grep` — læs og søg i filer
- **Piping/redirection:** `|` kæder kommandoer, `>` skriver (overskriver), `>>` appender
- **Filrettigheder:** `rwx` i tre grupper (ejer, gruppe, andre), ændres med `chmod`
- **SCP:** Krypteret filoverførsel over SSH

---

## Forberedte eksempler på computeren

| # | Demonstration | Forberedelse |
|---|---------------|--------------|
| 1 | Terminalen som begreb — `echo $0`, `which ls` | Terminal åben, klar til at køre |
| 2 | SSH nøglepar — `ssh-keygen -t ed25519`, `cat ~/.ssh/id_ed25519.pub` | (Eller brug eksisterende nøgle) |
| 3 | Filsystem — opret `~/eksamen/linux-demo/`, naviger, opret filer | Mappen klar eller oprettes live |
| 4 | `cat`, `head`, `tail`, `less`, `grep` — demonstrer på en logfil | En tekstfil med indhold (fx en log) |
| 5 | Piping — `history \| awk '{print $2}' \| sort \| uniq -c \| sort -rn \| head -5` | Terminal med lidt historik |
| 6 | Redirection — `>` vs `>>` vs `set -o noclobber` | Terminal |
| 7 | Filrettigheder — `ls -l`, `chmod 755`, `chmod u+x` | Et script eller en fil |
| 8 | SCP — overfør fil til/fra remote server og bekræft med SSH | Adgang til en cloud VM |

---

## Forventede opfølgende spørgsmål fra eksaminator

- *Hvad er forskellen på en terminal og en shell?*
- *Hvordan sikrer SSH public key authentication sig mod at nogen udgiver sig for at være serveren?*
- *Hvad sker der hvis du kører `>` på en fil der allerede findes?*
- *Hvordan adskiller `>>` sig fra `>` — hvornår bruger du hvilken?*
- *Forklar hvad `|` gør — giv et eksempel på en pipeline med 3+ kommandoer*
- *Hvad betyder filrettigheden `-rwxr-xr-x` — hvilke rettigheder har ejer, gruppe og andre?*
- *Hvad er forskellen på `scp` og `cp`?*
- *Hvordan forhindrer du at `>` ved et uheld overskriver en eksisterende fil?*
