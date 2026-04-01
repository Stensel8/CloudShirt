# CloudShirt

Korte implementatierepository voor schoolopdrachten binnen de Cloud Engineering-specialisatie.

Deze applicatie is gebaseerd op een Saxion-docentenvariant van eShopOnWeb en door mij omgebouwd voor opdrachten in Cloud Automation Concepts.

Gekoppelde module-repository:
- https://github.com/Stensel8/cloud-engineering/tree/main/cloud-automation-concepts

Gebruik in opdrachten:
- Assignment 1: AWS Basics
- Assignment 2: Docker in the Cloud
- Assignment 3: Cloud Orchestration

## Snelle Start (aanrader)

Gebruik de scripts in de map scripts:

```powershell
.\scripts\run-dotnet.ps1
```

```powershell
.\scripts\run-docker.ps1
```

Deze scripts gebruiken de waarden uit .env (of maken die aan vanuit .env.example).

## 1) Lokale .NET app (.NET 10)

Deze variant draait direct op je machine met twee processen: de MVC-webapp en de Public API.

### Services en poorten (lokaal)

| Service | Project | Rol | URL (HTTP/HTTPS) |
|---|---|---|---|
| Web | src/Web/Web.csproj | Frontend + server-side webapp | http://localhost:5000, https://localhost:5001 |
| PublicApi | src/PublicApi/PublicApi.csproj | API + Swagger | http://localhost:5098, https://localhost:5099 |

### Starten

```powershell
.\scripts\run-dotnet.ps1
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
- We gebruiken nu 1 compose-bestand: docker-compose.yml
- Er is geen aparte override-file meer nodig
- Database draait op PostgreSQL

### Containers en poortkoppelingen

| Container (service) | Image | Rol | Poortkoppeling host -> container |
|---|---|---|---|
| eshopwebmvc | eshopwebmvc:latest | Webapp | 5106 -> 80 |
| eshoppublicapi | eshoppublicapi:latest | Public API | 5200 -> 80 |
| postgres | postgres:16-alpine | Database | 5432 -> 5432 |

### Starten

```powershell
.\scripts\run-docker.ps1
```

Handmatig kan ook:

```powershell
docker compose up -d --build --remove-orphans
```

Endpoints (Docker):
- Web: http://localhost:5106
- Public API: http://localhost:5200
- Swagger: http://localhost:5200/swagger
- PostgreSQL: localhost:5432

Stoppen:

Stap 4 - Alles netjes stoppen en opruimen:

```powershell
docker compose down
```

## Wanneer gebruik je welke variant?

- Lokale .NET variant:
	Snelste feedback tijdens ontwikkelen en debuggen in Visual Studio/VS Code.
	Draait direct op je machine met de PostgreSQL container als database.

- Docker variant:
	Beste keuze voor integratietests, demo's en cloud-achtige runtimetests.
	Zelfde service-opzet als beoogde container-deployment (Web + PublicApi + PostgreSQL).

## Demo

<video src="Short-Demo.webm" controls playsinline width="100%"></video>

[Bekijk demo (WebM)](Short-Demo.webm)

## Credits

- Originele upstream: https://github.com/dotnet-architecture/eShopOnWeb
- Fork-basis voor deze variant: https://github.com/looking4ward/CloudShirt
