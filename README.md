# CloudShirt

Korte implementatierepository voor schoolopdrachten binnen de Cloud Engineering-specialisatie.

Deze applicatie is gebaseerd op een Saxion-docentenvariant van eShopOnWeb en door mij omgebouwd voor opdrachten in Cloud Automation Concepts.

Gekoppelde module-repository:
- https://github.com/Stensel8/cloud-engineering/tree/main/cloud-automation-concepts

Gebruik in opdrachten:
- Assignment 1: AWS Basics
- Assignment 2: Docker in the Cloud
- Assignment 3: Cloud Orchestration

## Build, Run, Test

```powershell
dotnet restore
dotnet build .\eShopOnWeb.sln
dotnet run --project .\src\PublicApi\PublicApi.csproj
dotnet run --project .\src\Web\Web.csproj --launch-profile Web
dotnet test .\eShopOnWeb.sln
```

## Demo

<video src="Short-Demo.webm" controls playsinline width="100%"></video>

## Containers

```powershell
docker-compose build
docker-compose up
```
