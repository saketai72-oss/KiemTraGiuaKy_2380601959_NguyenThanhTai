FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src
COPY ["src/Toeic2380601959.Web.Host/Toeic2380601959.Web.Host.csproj", "src/Toeic2380601959.Web.Host/"]
COPY ["src/Toeic2380601959.Web.Core/Toeic2380601959.Web.Core.csproj", "src/Toeic2380601959.Web.Core/"]
COPY ["src/Toeic2380601959.Application/Toeic2380601959.Application.csproj", "src/Toeic2380601959.Application/"]
COPY ["src/Toeic2380601959.Core/Toeic2380601959.Core.csproj", "src/Toeic2380601959.Core/"]
COPY ["src/Toeic2380601959.EntityFrameworkCore/Toeic2380601959.EntityFrameworkCore.csproj", "src/Toeic2380601959.EntityFrameworkCore/"]
WORKDIR "/src/src/Toeic2380601959.Web.Host"
RUN dotnet restore 

WORKDIR /src
COPY ["src/Toeic2380601959.Web.Host", "src/Toeic2380601959.Web.Host"]
COPY ["src/Toeic2380601959.Web.Core", "src/Toeic2380601959.Web.Core"]
COPY ["src/Toeic2380601959.Application", "src/Toeic2380601959.Application"]
COPY ["src/Toeic2380601959.Core", "src/Toeic2380601959.Core"]
COPY ["src/Toeic2380601959.EntityFrameworkCore", "src/Toeic2380601959.EntityFrameworkCore"]
WORKDIR "/src/src/Toeic2380601959.Web.Host"
RUN dotnet publish -c Release -o /publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0
EXPOSE 80
WORKDIR /app
COPY --from=build /publish .
ENTRYPOINT ["dotnet", "Toeic2380601959.Web.Host.dll"]
