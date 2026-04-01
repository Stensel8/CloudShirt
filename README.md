# CloudShirt

CloudShirt is a .NET 10 sample ecommerce app based on the eShopOnWeb reference architecture. The solution includes the main Web app, a PublicApi service, Blazor admin components, and unit/integration/functional tests.

## Cloud Engineering Assignment Sync

This repository is the implementation base used by the Cloud Automation Concepts module in the Cloud Engineering specialization.

- Module README: https://github.com/Stensel8/cloud-engineering/blob/main/cloud-automation-concepts/README.md
- CloudShirt must stay in sync with the three assignment stages documented there.

### Exported hand-ins (present in this repo)

1. Assignment 1 - AWS Basics
	- [Hand-in assignment 1 - AWS basics - Cloud Engineering (2025-2026).html](Hand-in%20assignment%201%20-%20AWS%20basics%20-%20Cloud%20Engineering%20%282025-2026%29.html)
2. Assignment 2 - Docker in the Cloud
	- [Hand-in assignment 2 - Docker in the Cloud - Cloud Engineering (2025-2026).html](Hand-in%20assignment%202%20-%20Docker%20in%20the%20Cloud%20-%20Cloud%20Engineering%20%282025-2026%29.html)
3. Assignment 3 - Cloud Orchestration
	- [Hand-in assignment 3 - Cloud orchestration - Cloud Engineering (2025-2026).html](Hand-in%20assignment%203%20-%20Cloud%20orchestration%20-%20Cloud%20Engineering%20%282025-2026%29.html)

## Current stack

- .NET 10 (`net10.0`)
- ASP.NET Core MVC, Razor Pages, Blazor WebAssembly
- Entity Framework Core with SQL Server or in-memory storage for development
- Dockerized Web and PublicApi services

## Demo

<video src="Short-Demo.webm" controls playsinline width="100%"></video>

The original `Short-Demo.mp4` is kept in the repository, but the WebM version is the preferred compact format for display.

## Run locally

```powershell
dotnet restore
dotnet build .\eShopOnWeb.sln
dotnet run --project .\src\PublicApi\PublicApi.csproj
dotnet run --project .\src\Web\Web.csproj --launch-profile Web
```

The web app is available at `https://localhost:5001/`. If you run against a persistent SQL Server database, apply the EF Core migrations first.

## Docker

```powershell
docker-compose build
docker-compose up
```

## Tests

```powershell
dotnet test .\eShopOnWeb.sln
```

## Notes

- The repo has been modernized to .NET 10 and current Docker base images.
- A short modernization log is available in [MODERNIZATION_IMPROVEMENTS.md](MODERNIZATION_IMPROVEMENTS.md).
- This repository is intentionally kept as a dependency for the assignments in [cloud-engineering](https://github.com/Stensel8/cloud-engineering).
- The Docker Swarm stack remains part of the repo because those assignments still depend on it.
