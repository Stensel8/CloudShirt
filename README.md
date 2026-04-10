# CloudShirt (.NET)

> [!WARNING]
> **Deprecated vanaf juni 2026.** Deze applicatie is puur gebouwd als schooldemo en wordt niet verder doorontwikkeld. De repository wordt niet meer onderhouden.

Demo-project voor school met dezelfde app in twee .NET-architecturen:

- Monoliet (lokaal, zonder app-containers)
- Microservices (Docker Compose)

De microservices-variant gebruikt PostgreSQL.
De monoliet gebruikt standaard in-memory, met optioneel PostgreSQL via Docker.

## Starten

Monoliet:

```powershell
.\scripts\run-dotnet.ps1
```

Monoliet met Docker-PostgreSQL (optioneel):

```powershell
.\scripts\run-dotnet.ps1 -DbMode docker
```

Microservices (Docker):

```powershell
.\scripts\run-docker.ps1
```

Swarm:

```powershell
.\scripts\run-swarm.ps1
```

Stoppen:

```powershell
.\scripts\stop-dotnet.ps1
.\scripts\stop-docker.ps1
.\scripts\stop-swarm.ps1
```

## Demo-poorten

- Web: http://localhost:5106
- Public API: http://localhost:5200
- Swagger: http://localhost:5200/swagger
- PostgreSQL: localhost:5432

## Monoliet database-modus

- Standaard: in-memory database (geen Docker nodig)
- Optioneel: alleen database als Docker-container (`-DbMode docker`)

In-memory is ideaal voor demo's: snel opstarten en volledig monolithisch.
Let op: in-memory data is niet persistent en wordt gereset bij stoppen/herstarten.

## Doel

Dit project laat zien dat dezelfde business-app werkt als:

- .NET monoliet
- .NET microservices

## Gerelateerde repositories

Dit project maakt deel uit van een driehoek van samenhangende repo's:

| Repository | Rol |
|------------|-----|
| **[Stensel8/CloudShirt](https://github.com/Stensel8/CloudShirt)** *(deze repo)* | .NET-applicatie - monoliet én microservices; basis voor Assignment 1 |
| [Stensel8/CloudShirt-Hugo](https://github.com/Stensel8/CloudShirt-Hugo) | Go/Hugo-variant van dezelfde use-case; gebruikt in Assignment 2 (Docker Swarm) |
| [stensel8/cloud-engineering](https://github.com/stensel8/cloud-engineering/tree/main/cloud-automation-concepts) | Schoolopdracht IaC (AWS/Terraform/Ansible) waarvoor beide apps zijn gebouwd |

CloudShirt staat als git submodule in de cloud-engineering repo, zodat de koppeling versievast blijft.

## Credits

Dit project is gemaakt door **[Stensel8](https://github.com/Stensel8)** en **[Hintenhaus04](https://github.com/Hintenhaus04)** als schoolopdracht (Cloud Engineering, jaar 3). De opdracht vroeg om een IaC-infrastructuur op AWS op te zetten met eigen gedockerized applicaties - dat werd de aanleiding om zelf twee apps te bouwen.

### Upstreams & inspiratie

| Bron | Beschrijving |
|------|-------------|
| [looking4ward/CloudShirt](https://github.com/looking4ward/CloudShirt) | Upstream van de docent, als startpunt voor deze opdracht |
| [NimblePros/eShopOnWeb](https://github.com/NimblePros/eShopOnWeb) | Onderhouden fork van eShopOnWeb door een .NET-community maintainer |
| [dotnet-architecture/eShopOnWeb](https://github.com/dotnet-architecture/eShopOnWeb) | Originele Microsoft demo-applicatie (deprecated / end-of-life) |

### Tooling

- Ontwikkeld met hulp van **[Claude Code](https://claude.ai/code)** (Anthropic) als AI-assistent bij de implementatie.
