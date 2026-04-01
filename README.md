# CloudShirt

Korte implementatierepository voor schoolopdrachten binnen de Cloud Engineering-specialisatie.

Deze applicatie is gebaseerd op een Saxion-docentenvariant van eShopOnWeb en door mij omgebouwd voor opdrachten in Cloud Automation Concepts.

Gekoppelde module-repository:
- https://github.com/Stensel8/cloud-engineering/tree/main/cloud-automation-concepts

Gebruik in opdrachten:
- Assignment 1: AWS Basics
- Assignment 2: Docker in the Cloud
- Assignment 3: Cloud Orchestration

## 1) Lokale .NET app (.NET 10)

Deze variant draait direct op je machine met twee processen: de MVC-webapp en de Public API.

### Services en poorten (lokaal)

| Service | Project | Rol | URL (HTTP/HTTPS) |
|---|---|---|---|
| Web | src/Web/Web.csproj | Frontend + server-side webapp | http://localhost:5000, https://localhost:5001 |
| PublicApi | src/PublicApi/PublicApi.csproj | API + Swagger | http://localhost:5098, https://localhost:5099 |

### Starten

```powershell
dotnet restore
dotnet build .\eShopOnWeb.sln
dotnet run --project .\src\PublicApi\PublicApi.csproj --launch-profile PublicApi
dotnet run --project .\src\Web\Web.csproj --launch-profile Web
```

Swagger (lokaal):
- http://localhost:5098/swagger
- https://localhost:5099/swagger

Tests:

```powershell
dotnet test .\eShopOnWeb.sln
```

## 2) Docker app (containers)

Deze variant draait met Docker Compose en gebruikt drie containers.

Belangrijk:
- We gebruiken nu 1 compose-bestand: `docker-compose.yml`
- Er is geen aparte override-file meer nodig

### Containers en poortkoppelingen

| Container (service) | Image | Rol | Poortkoppeling host -> container |
|---|---|---|---|
| eshopwebmvc | eshopwebmvc:latest | Webapp | 5106 -> 80 |
| eshoppublicapi | eshoppublicapi:latest | Public API | 5200 -> 80 |
| sqlserver | mcr.microsoft.com/azure-sql-edge | Database | 1433 -> 1433 |

### Starten

Stap 1 - Images bouwen:

```powershell
docker compose build
```

Stap 2 - Containers starten (op de achtergrond):

```powershell
docker compose up -d
```

Stap 3 - Controleren of alles draait:

```powershell
docker compose ps
```

Endpoints (Docker):
- Web: http://localhost:5106
- Public API: http://localhost:5200
- Swagger: http://localhost:5200/swagger
- SQL Server: localhost,1433

Stoppen:

Stap 4 - Alles netjes stoppen en opruimen:

```powershell
docker compose down
```

## Demo

<video src="Short-Demo.webm" controls playsinline width="100%"></video>

[Bekijk demo (WebM)](Short-Demo.webm)

## Credits

- Originele upstream: https://github.com/dotnet-architecture/eShopOnWeb
- Fork-basis voor deze variant: https://github.com/looking4ward/CloudShirt
