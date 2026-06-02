FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source
COPY src/*.csproj .
RUN dotnet restore
COPY src/ .
RUN dotnet publish -c Release -o /app/out /p:UseAppHost=false
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 8080
ENTRYPOINT ["dotnet", "eShopLinuxApp.dll"]