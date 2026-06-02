using Microsoft.AspNetCore.Builder;
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();
app.MapGet("/", () => "Welcome to eShop Modernized Backoffice Running on Linux Containers via GitOps!");
app.Run();
