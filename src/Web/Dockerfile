FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Stap 1 - Kopieer eerst alleen oplossing- en projectbestanden.
# Waarom: Docker kan de 'restore'-laag dan hergebruiken, wat builds sneller maakt.
COPY *.sln ./
COPY Directory.Build.props ./
COPY Directory.Packages.props ./
COPY src/ApplicationCore/ApplicationCore.csproj src/ApplicationCore/
COPY src/Infrastructure/Infrastructure.csproj src/Infrastructure/
COPY src/BlazorShared/BlazorShared.csproj src/BlazorShared/
COPY src/BlazorAdmin/BlazorAdmin.csproj src/BlazorAdmin/
COPY src/Web/Web.csproj src/Web/

# Stap 2 - Download alle NuGet-afhankelijkheden voor de Web-app.
RUN dotnet restore src/Web/Web.csproj

# Stap 3 - Kopieer daarna de rest van de broncode.
COPY src/ src/

# Stap 4 - Publiceer de applicatie in release-modus.
WORKDIR /src/src/Web
RUN dotnet publish Web.csproj -c Release -o /app/publish --no-restore

# Stap 5 - Gebruik een kleinere runtime-image voor het draaien van de app.
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Healthchecks in docker-compose rely on curl being present.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends curl \
	&& rm -rf /var/lib/apt/lists/*

# Stap 6 - Neem alleen de gepubliceerde output mee naar de runtime-container.
COPY --from=build /app/publish ./

# Stap 7 - Start de Web-app.
ENTRYPOINT ["dotnet", "Web.dll"]
