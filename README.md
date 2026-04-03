# CloudShirt

Korte implementatierepository voor schoolopdrachten binnen de Cloud Engineering-specialisatie.

Deze applicatie is gebaseerd op een Saxion-docentenvariant en door mij omgebouwd voor opdrachten in Cloud Automation Concepts onder de naam CloudShirt.

Gekoppelde module-repository:
- https://github.com/Stensel8/cloud-engineering/tree/main/cloud-automation-concepts

Gebruik in opdrachten:
- Assignment 1: AWS Basics
- Assignment 2: Docker in the Cloud
- Assignment 3: Cloud Orchestration

## Starten en stoppen

Gebruik de scripts in de map scripts:

```powershell
.\scripts\run-dotnet.ps1
```

```powershell
.\scripts\run-docker.ps1
```

Stoppen:

```powershell
.\scripts\stop-dotnet.ps1
```

```powershell
.\scripts\stop-docker.ps1
```

Deze scripts gebruiken de waarden uit .env (of maken die aan vanuit .env.example).
Als een variant al draait, geven de run-scripts een herstartmelding en starten opnieuw op.

## 1) Lokale .NET app (.NET 10)

Monolithische variant. Draait lokaal in één app met SQLite.

### Starten

```powershell
.\scripts\run-dotnet.ps1
```

Tests:

```powershell
dotnet test .\*.sln
```

## 2) Docker app (containers)

Containervariant. Draait met Docker Compose en PostgreSQL.

### Starten

```powershell
.\scripts\run-docker.ps1
```

## Wanneer gebruik je welke variant?

- Lokale .NET variant: snel opstarten en debuggen, geen Docker nodig, data in SQLite.
- Docker variant: test de containersetup zoals die ook in de cloud draait, data in PostgreSQL.

## Data en state

- SQLite (lokale .NET) en PostgreSQL (Docker) delen niet automatisch dezelfde data/state.
- Bij wisselen van modus start je dus met de state van de bijbehorende database.

## Demo

![Demo screenshot](demo.avif)

<video src="Short-Demo.webm" controls playsinline width="100%"></video>

[Bekijk demo (WebM)](Short-Demo.webm)

## Credits

- Repository: https://github.com/Stensel8/CloudShirt
