# CloudShirt (.NET)

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

### Snel lokaal PostgreSQL opzetten (Windows)

```powershell
winget install -e --id PostgreSQL.PostgreSQL
```

Maak daarna databases aan:

```sql
CREATE DATABASE eshop_catalog;
CREATE DATABASE eshop_identity;
```

Gebruik dezelfde credentials als in `.env` (`POSTGRES_USER` en `POSTGRES_PASSWORD`) zodat monoliet en Docker met dezelfde data-setup werken.

## Doel

Dit project laat zien dat dezelfde business-app werkt als:

- .NET monoliet
- .NET microservices