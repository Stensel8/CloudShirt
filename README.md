# CloudShirt

> Implementatierepository voor de Cloud Engineering-specialisatie (Cloud Automation Concepts)

## Over deze repository

CloudShirt bevat de applicatie en infrastructuur-artefacten die gebruikt worden binnen de drie assignmentfases van het vak Cloud Automation Concepts.

Deze applicatie is oorspronkelijk gebaseerd op de eShopOnWeb-variant van een Saxion-docent en is daarna door mij (Stensel8) omgebouwd en gemoderniseerd voor gebruik binnen de Cloud Engineering-opdrachten.

Deze repository is gekoppeld aan:
- https://github.com/Stensel8/cloud-engineering/tree/main/cloud-automation-concepts

## Koppeling met Cloud Automation Concepts

In Cloud Automation Concepts gebruik ik CloudShirt als de kernapplicatie om requirements per assignmentfase uit te werken en af te vinken.

- Assignment 1: AWS Basics
- Assignment 2: Docker in the Cloud
- Assignment 3: Cloud Orchestration

Cross-referentie:
- Deze repository (CloudShirt) bevat de applicatie + deploymentartefacten.
- De module-repository bevat de opdrachtcontext, leerdoelen en requirement-overzicht.

## Inleverfasen (koppeling met cloud-automation-concepts)

1. Assignment 1: AWS Basics
   - Focus: basisinfrastructuur en AWS-resources via IaC
2. Assignment 2: Docker in the Cloud
   - Focus: containerisatie, build/deploy-flow en Swarm
3. Assignment 3: Cloud Orchestration
   - Focus: orchestration en multi-cloud deployment

> Opmerking: Brightspace-exportbestanden (HTML) horen niet in deze repository en worden niet als bron van bewijs gebruikt.

## Technische stack

- .NET 10 (`net10.0`)
- ASP.NET Core MVC, Razor Pages, Blazor WebAssembly
- Entity Framework Core (SQL Server of InMemory voor development)
- Docker Compose + Swarm stack (voor assignment-context)

## Build, Run, Test

### Build

```powershell
dotnet restore
dotnet build .\eShopOnWeb.sln
```

### Run

```powershell
dotnet run --project .\src\PublicApi\PublicApi.csproj
dotnet run --project .\src\Web\Web.csproj --launch-profile Web
```

Web draait standaard op `https://localhost:5001/`.

### Test

```powershell
dotnet test .\eShopOnWeb.sln
```

## Containers

```powershell
docker-compose build
docker-compose up
```

De `swarm-stack.yml` blijft bewust onderdeel van deze repo, omdat de opdrachten binnen Cloud Engineering hiervan afhankelijk zijn.

## Demo

<video src="Short-Demo.webm" controls playsinline width="100%"></video>

`Short-Demo.mp4` blijft als bronbestand aanwezig; `Short-Demo.webm` is de efficiënte variant voor weergave in de repository.
