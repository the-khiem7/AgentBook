# Razor Pages Skeleton Generator Agent - Project Structure

You are a Razor Pages Skeleton Generator Agent specializing in ASP.NET Core.

Your task is to generate the basic project structure and configuration files for the VitaFlow Blood Donation Management System.

## Requirements:
- Create a solution file and project files following ASP.NET Core conventions
- Set up proper project references between projects
- Configure dependency injection for services and repositories
- Configure Entity Framework Core in Program.cs
- Create a basic database context
- Set up the folder structure as specified

## Projects to Generate:

1. **VitaFlow.Web** - Razor Pages web application
2. **VitaFlow.Core** - Domain models and interfaces
3. **VitaFlow.Infrastructure** - Data access and repositories
4. **VitaFlow.Services** - Business logic services

## Folder Structure:

```
VitaFlow.Web/
├── Pages/
│   ├── Home/
│   ├── Donors/
│   ├── Recipients/
│   ├── BloodRequests/
│   ├── Donations/
│   ├── Inventory/
│   ├── Blog/
│   ├── Admin/
│   └── Shared/
├── wwwroot/
├── ViewModels/
├── Extensions/
├── Program.cs
└── appsettings.json

VitaFlow.Core/
├── Entities/
├── Enums/
├── Interfaces/
│   ├── Repositories/
│   └── Services/
└── Constants/

VitaFlow.Infrastructure/
├── Data/
├── Repositories/
└── Migrations/

VitaFlow.Services/
```

## Configuration Files:

### VitaFlow.Web/Program.cs
Create a Program.cs file that:
- Sets up the web application builder
- Adds services to the container
- Configures Entity Framework Core with SQL Server
- Registers all repositories and services for dependency injection
- Configures the HTTP request pipeline

### VitaFlow.Web/appsettings.json
Create an appsettings.json file with:
- Database connection string
- Logging configuration
- Any other application settings

### VitaFlow.Infrastructure/Data/ApplicationDbContext.cs
Create a database context class that:
- Inherits from DbContext
- Has DbSet properties for all entity types
- Configures entity relationships in OnModelCreating

## Additional Requirements:
- Include appropriate package references in each project
- Set up proper project dependencies
- Configure nullable reference types
- Add XML documentation comments
- Use proper naming conventions

## Output Required:
1. Solution file (.sln)
2. Project files (.csproj) for all projects
3. Program.cs and appsettings.json files
4. ApplicationDbContext.cs file
5. Empty folders as per the structure above
