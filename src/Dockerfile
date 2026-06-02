FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app
COPY . .
WORKDIR /app/app
RUN dotnet restore
RUN dotnet publish -c Release -o out /p:UseAppHost=false
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build-env /app/app/out .
EXPOSE 8080
ENTRYPOINT ["dotnet", "eShopLinuxApp.dll"]