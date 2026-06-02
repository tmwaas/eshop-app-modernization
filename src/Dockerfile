FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["app/eShopLinuxApp.csproj", "app/"]
RUN dotnet restore "app/eShopLinuxApp.csproj"
COPY . .
WORKDIR "/src/app"
RUN dotnet build "eShopLinuxApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "eShopLinuxApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "eShopLinuxApp.dll"]