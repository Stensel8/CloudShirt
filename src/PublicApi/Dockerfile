FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Stap 1 - Kopieer eerst alleen oplossing- en projectbestanden.
# Waarom: Docker kan de 'restore'-laag dan hergebruiken, wat builds sneller maakt.
COPY *.sln ./
COPY src/ApplicationCore/ApplicationCore.csproj src/ApplicationCore/
COPY src/Infrastructure/Infrastructure.csproj src/Infrastructure/
COPY src/BlazorShared/BlazorShared.csproj src/BlazorShared/
COPY src/PublicApi/PublicApi.csproj src/PublicApi/

# Stap 2 - Download alle NuGet-afhankelijkheden voor de Public API.
RUN dotnet restore src/PublicApi/PublicApi.csproj

# Stap 3 - Kopieer daarna de rest van de broncode.
COPY src/ src/

# Stap 4 - Publiceer de API in release-modus.
WORKDIR /src/src/PublicApi
RUN dotnet publish PublicApi.csproj -c Release -o /app/publish --no-restore

# Stap 5 - Gebruik een kleinere runtime-image voor het draaien van de API.
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Stap 6 - Neem alleen de gepubliceerde output mee naar de runtime-container.
COPY --from=build /app/publish .

# Stap 7 - Start de Public API.
ENTRYPOINT ["dotnet", "PublicApi.dll"]