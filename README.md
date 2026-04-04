# CloudShirt (.NET)

Demo-project voor school met dezelfde app in twee .NET-architecturen:

- Monoliet (lokaal, zonder app-containers)
- Microservices (Docker Compose)

Beide gebruiken PostgreSQL.

## Starten

Monoliet:

```powershell
.\scripts\run-dotnet.ps1
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

## Doel

Dit project laat zien dat dezelfde business-app werkt als:

- .NET monoliet
- .NET microservices