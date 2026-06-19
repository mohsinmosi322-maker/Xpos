# PharmaX Enterprise

PharmaX Enterprise is a comprehensive pharmaceutical retail and distribution management system built on Clean Architecture principles.

## Project Structure

```
PharmaX/
├── docs/                    # Documentation
│   ├── ADR/                 # Architecture Decision Records
│   ├── 01-architecture-overview.md
│   ├── 02-module-map.md
│   ├── 03-domain-model.md
│   ├── 04-repository-standards.md
│   ├── 05-git-workflow.md
│   ├── 06-development-process.md
│   ├── 07-non-functional-requirements.md
│   ├── 08-coding-standards.md
│   ├── 09-error-handling.md
│   ├── 10-logging-strategy.md
│   ├── 11-security-architecture.md
│   ├── 12-database-standards.md
│   └── README.md
├── src/                     # Source code
│   ├── PharmaX.Domain       # Domain layer (entities, business rules)
│   ├── PharmaX.Application  # Application layer (use cases, services)
│   ├── PharmaX.Infrastructure # Infrastructure layer (data access, external services)
│   ├── PharmaX.Persistence  # Persistence configuration
│   ├── PharmaX.WinForms     # Presentation layer (Windows Forms UI)
│   ├── PharmaX.Shared       # Shared utilities and cross-cutting concerns
│   ├── PharmaX.Tests        # Test projects
│   └── Directory.Build.props # Common build properties
├── .editorconfig            # Editor and code style configuration
├── .gitignore               # Git ignore patterns
└── PharmaX.sln              # Visual Studio solution
```

## Technology Stack

- **Platform**: .NET 8 LTS
- **UI Framework**: Windows Forms
- **Database**: SQL Server 2019/2022
- **Data Access**: ADO.NET with Dapper
- **Architecture**: Clean Architecture
- **Patterns**: Repository Pattern, Unit of Work, Dependency Injection

## Documentation

See the [docs/README.md](docs/README.md) for complete documentation index.

### Key Documents

- [Architecture Overview](docs/01-architecture-overview.md)
- [Non-Functional Requirements](docs/07-non-functional-requirements.md)
- [Coding Standards](docs/08-coding-standards.md)
- [Security Architecture](docs/11-security-architecture.md)

### Architecture Decision Records

- [ADR-0001: Why Clean Architecture](docs/ADR/ADR-0001-why-clean-architecture.md)
- [ADR-0002: Why Windows Forms](docs/ADR/ADR-0002-why-windows-forms.md)
- [ADR-0003: Why SQL Server](docs/ADR/ADR-0003-why-sql-server.md)
- [ADR-0004: Why ADO.NET Instead of Entity Framework](docs/ADR/ADR-0004-why-ado-net.md)
- [ADR-0005: Why Repository Pattern + Unit of Work](docs/ADR/ADR-0005-why-repository-pattern.md)
- [ADR-0006: Target .NET Version Strategy](docs/ADR/ADR-0006-dotnet-version-strategy.md)

## Getting Started

### Prerequisites

- .NET 8 SDK
- Visual Studio 2022 or JetBrains Rider
- SQL Server 2019/2022 (for development)

### Build

```bash
dotnet restore PharmaX.sln
dotnet build PharmaX.sln
```

### Run Tests

```bash
dotnet test PharmaX.sln
```

## Contributing

Please read our [Development Process](docs/06-development-process.md) and [Git Workflow](docs/05-git-workflow.md) before contributing.

## License

Copyright © PharmaX Enterprise. All rights reserved.
