# CloudShirt

Korte implementatierepository voor schoolopdrachten binnen de Cloud Engineering-specialisatie.

Deze applicatie is gebaseerd op een Saxion-docentenvariant van eShopOnWeb en door mij omgebouwd voor opdrachten in Cloud Automation Concepts.

Gekoppelde module-repository:
- https://github.com/Stensel8/cloud-engineering/tree/main/cloud-automation-concepts

Gebruik in opdrachten:
- Assignment 1: AWS Basics
- Assignment 2: Docker in the Cloud
- Assignment 3: Cloud Orchestration

## 1) Oude monolithische app (.NET 10)

Dit is de klassieke CloudShirt-webapplicatie op .NET 10 (met bijbehorende API en tests).

### Build, run, test

```powershell
dotnet restore
dotnet build .\eShopOnWeb.sln
dotnet run --project .\src\PublicApi\PublicApi.csproj
dotnet run --project .\src\Web\Web.csproj --launch-profile Web
dotnet test .\eShopOnWeb.sln
```

## 2) Microservices-variant (Docker)

Voor schaalbaarheid gebruik ik een container-setup waarmee services los uitgerold kunnen worden.

```powershell
docker compose build
docker compose up
```

## Demo

<video src="Short-Demo.webm" controls playsinline width="100%"></video>

[Bekijk demo (WebM)](Short-Demo.webm)

## Credits

- Originele upstream: https://github.com/dotnet-architecture/eShopOnWeb
- Fork-basis voor deze variant: https://github.com/looking4ward/CloudShirt
