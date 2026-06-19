# Coding Standards

**Version:** 1.0  
**Document ID:** CODE-001  
**Created:** WO-0002  
**Related:** [Repository Standards](./04-repository-standards.md)

---

## 1. Introduction

This document defines the coding standards for PharmaX Enterprise. All developers must adhere to these standards to ensure code consistency, maintainability, and quality.

---

## 2. Naming Conventions

### 2.1 General Rules

- Use PascalCase for types (classes, interfaces, structs, enums, delegates)
- Use camelCase for local variables and method parameters
- Use PascalCase for methods and properties
- Use UPPERCASE for constants
- Prefix private fields with underscore (_)
- Avoid abbreviations unless universally understood

### 2.2 Specific Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Classes | PascalCase | `Company`, `UserService` |
| Interfaces | PascalCase with I prefix | `ICompanyRepository`, `IService` |
| Methods | PascalCase | `GetByIdAsync`, `CreateCompany` |
| Properties | PascalCase | `CompanyName`, `IsActive` |
| Local Variables | camelCase | `company`, `userService` |
| Parameters | camelCase | `companyId`, `companyName` |
| Private Fields | _camelCase | `_companyRepository`, `_logger` |
| Constants | UPPERCASE | `MaxRetryCount`, `DefaultTimeout` |
| Static Readonly | PascalCase | `ConnectionString`, `ApiKey` |
| Enums | PascalCase | `OrderStatus`, `UserRole` |
| Enum Values | PascalCase | `Pending`, `Approved`, `Rejected` |

### 2.3 Async Method Naming

- Async methods must end with `Async` suffix
- Return `Task` or `Task<T>`
- Never use `async void` except for event handlers

```csharp
// Correct
public async Task<Company> GetCompanyByIdAsync(int id);
public async Task CreateCompanyAsync(Company company);

// Incorrect
public async Task<Company> GetCompanyById(int id);
public async void ProcessCompanyAsync(Company company);
```

### 2.4 Repository Naming

- Interface: `I{Entity}Repository`
- Implementation: `{Entity}Repository`
- Specialized methods: `{Operation}{Entity}{Async}`

```csharp
public interface ICompanyRepository : IRepository<Company>
{
    Task<Company?> GetWithBranchesAsync(int id);
    Task<IEnumerable<Company>> SearchByNameAsync(string searchTerm);
}

public class CompanyRepository : BaseRepository<Company>, ICompanyRepository
{
    // Implementation
}
```

---

## 3. Folder Conventions

### 3.1 Project Structure

```
PharmaX.Domain/
├── Entities/
├── ValueObjects/
├── Events/
├── Exceptions/
├── Specifications/
└── Interfaces/

PharmaX.Application/
├── Services/
├── DTOs/
├── Commands/
├── Queries/
├── Validators/
├── Mappers/
└── Interfaces/

PharmaX.Infrastructure/
├── Data/
│   ├── ConnectionFactory.cs
│   └── UnitOfWork.cs
├── Repositories/
├── Services/
├── External/
└── Configuration/

PharmaX.WinForms/
├── Forms/
│   ├── Main/
│   ├── Company/
│   └── Branch/
├── Controls/
├── Presenters/
├── ViewModels/
├── Helpers/
└── Resources/

PharmaX.Tests/
├── Domain/
├── Application/
├── Infrastructure/
└── Integration/
```

### 3.2 File Organization

- One class per file (exceptions allowed for small related types)
- File name matches class name
- Nested classes in separate files when complex
- Group related files in feature folders (for large modules)

---

## 4. Namespace Conventions

### 4.1 Root Namespace

- Root: `PharmaX`
- Layer namespaces: `PharmaX.{Layer}`

### 4.2 Namespace Structure

```csharp
// Domain layer
namespace PharmaX.Domain.Entities;
namespace PharmaX.Domain.ValueObjects;
namespace PharmaX.Domain.Events;
namespace PharmaX.Domain.Exceptions;
namespace PharmaX.Domain.Interfaces;

// Application layer
namespace PharmaX.Application.Services;
namespace PharmaX.Application.DTOs;
namespace PharmaX.Application.Commands;
namespace PharmaX.Application.Queries;
namespace PharmaX.Application.Validators;

// Infrastructure layer
namespace PharmaX.Infrastructure.Data;
namespace PharmaX.Infrastructure.Repositories;
namespace PharmaX.Infrastructure.Services;
namespace PharmaX.Infrastructure.External;

// Presentation layer
namespace PharmaX.WinForms.Forms.Company;
namespace PharmaX.WinForms.Presenters.Company;
namespace PharmaX.WinForms.Controls;
namespace PharmaX.WinForms.ViewModels;
```

### 4.3 Using Statements

- System namespaces first
- Third-party namespaces second
- PharmaX namespaces last
- Within each group, alphabetically sorted
- Use implicit usings where appropriate

```csharp
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

using Dapper;
using Microsoft.Extensions.Logging;

using PharmaX.Domain.Entities;
using PharmaX.Domain.Interfaces;
```

---

## 5. SOLID Compliance

### 5.1 Single Responsibility Principle (SRP)

- Each class should have one reason to change
- Keep methods under 50 lines when possible
- Keep classes under 500 lines when possible
- Split large classes into smaller, focused classes

```csharp
// Violation: Multiple responsibilities
public class CompanyService
{
    public void CreateCompany(Company company) { }
    public void ValidateCompany(Company company) { }
    public void SendWelcomeEmail(Company company) { }
    public void LogAudit(string action) { }
}

// Compliant: Separated responsibilities
public class CompanyService
{
    private readonly ICompanyValidator _validator;
    private readonly IEmailService _emailService;
    private readonly IAuditLogger _auditLogger;
    
    public void CreateCompany(Company company) 
    {
        _validator.Validate(company);
        // Create logic
        _emailService.SendWelcome(company);
        _auditLogger.Log("Company created");
    }
}
```

### 5.2 Open/Closed Principle (OCP)

- Classes should be open for extension, closed for modification
- Use interfaces and abstraction
- Prefer composition over inheritance

### 5.3 Liskov Substitution Principle (LSP)

- Derived classes must be substitutable for base classes
- Don't throw NotImplementedException in overrides
- Honor base class contracts

### 5.4 Interface Segregation Principle (ISP)

- Many specific interfaces better than one general interface
- Keep interfaces small and focused
- Avoid "fat" interfaces

```csharp
// Violation: Fat interface
public interface IRepository
{
    Task GetByIdAsync(int id);
    Task GetAllAsync();
    Task AddAsync(object entity);
    Task UpdateAsync(object entity);
    Task DeleteAsync(int id);
    Task ExecuteStoredProcedureAsync(string name, object parameters);
    Task ExecuteRawSqlAsync(string sql);
}

// Compliant: Segregated interfaces
public interface IRepository<T>
{
    Task<T?> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<int> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
}

public interface ISqlExecutor
{
    Task ExecuteStoredProcedureAsync(string name, object parameters);
    Task<IEnumerable<T>> ExecuteRawSqlAsync<T>(string sql);
}
```

### 5.5 Dependency Inversion Principle (DIP)

- Depend on abstractions, not concretions
- Inject dependencies via constructor
- Avoid service locator pattern

```csharp
// Violation: Depends on concrete class
public class CompanyService
{
    private readonly CompanyRepository _repository;
    
    public CompanyService()
    {
        _repository = new CompanyRepository();
    }
}

// Compliant: Depends on abstraction
public class CompanyService
{
    private readonly ICompanyRepository _repository;
    
    public CompanyService(ICompanyRepository repository)
    {
        _repository = repository;
    }
}
```

---

## 6. Dependency Injection

### 6.1 Constructor Injection

- Use constructor injection as primary pattern
- Mark injected dependencies as private readonly
- Avoid property injection except for optional dependencies

```csharp
public class CompanyService
{
    private readonly ICompanyRepository _repository;
    private readonly ILogger<CompanyService> _logger;
    
    public CompanyService(
        ICompanyRepository repository,
        ILogger<CompanyService> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }
}
```

### 6.2 Service Registration

- Register services in composition root only
- Use appropriate lifetimes (Singleton, Scoped, Transient)
- Document service lifetime requirements

```csharp
// Composition Root (Program.cs or Module)
services.AddScoped<ICompanyRepository, CompanyRepository>();
services.AddScoped<ICompanyService, CompanyService>();
services.AddSingleton<ICacheService, CacheService>();
services.AddTransient<IEmailService, EmailService>();
```

### 6.3 Lifetime Guidelines

| Lifetime | Use Case | Examples |
|----------|----------|----------|
| Singleton | Stateless services, cache | Configuration, CacheService |
| Scoped | Per-request/unit-of-work | Repositories, UnitOfWork |
| Transient | Lightweight, stateless | Validators, Mappers |

---

## 7. Exception Handling

### 7.1 Exception Hierarchy

```
Exception
├── BusinessException
│   ├── ValidationException
│   ├── AuthorizationException
│   └── NotFoundException
├── InfrastructureException
│   ├── DatabaseException
│   └── ExternalServiceException
└── TechnicalException
```

### 7.2 Throwing Exceptions

- Throw specific exceptions, not generic Exception
- Include meaningful error messages
- Include relevant data in exception
- Never throw from catch without wrapping or logging

```csharp
// Correct
if (company == null)
    throw new NotFoundException($"Company with ID {id} not found");

if (!user.HasPermission(Permissions.CompanyEdit))
    throw new AuthorizationException("User lacks CompanyEdit permission");

// Incorrect
if (company == null)
    throw new Exception("Company not found");
```

### 7.3 Catching Exceptions

- Catch specific exceptions when possible
- Log exceptions at appropriate level
- Don't swallow exceptions silently
- Use exception filters when appropriate

```csharp
try
{
    await _repository.AddAsync(company);
}
catch (DbException ex) when (ex.Number == 2627) // Unique constraint
{
    _logger.LogWarning(ex, "Duplicate company name: {Name}", company.Name);
    throw new BusinessException("Company name already exists");
}
catch (DbException ex)
{
    _logger.LogError(ex, "Database error adding company {CompanyId}", company.Id);
    throw new InfrastructureException("Failed to create company", ex);
}
```

---

## 8. Validation

### 8.1 Input Validation

- Validate all public method inputs
- Fail fast on invalid input
- Use guard clauses
- Separate validation from business logic

```csharp
public async Task<Company> CreateCompanyAsync(CreateCompanyRequest request)
{
    if (request == null)
        throw new ArgumentNullException(nameof(request));
    
    if (string.IsNullOrWhiteSpace(request.Name))
        throw new ValidationException("Company name is required");
    
    if (request.Name.Length > 100)
        throw new ValidationException("Company name cannot exceed 100 characters");
    
    // Business logic continues...
}
```

### 8.2 FluentValidation

- Use FluentValidation for complex validation rules
- Create separate validator classes
- Keep validators testable

```csharp
public class CreateCompanyRequestValidator : AbstractValidator<CreateCompanyRequest>
{
    public CreateCompanyRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Company name is required")
            .MaximumLength(100).WithMessage("Company name cannot exceed 100 characters");
        
        RuleFor(x => x.Code)
            .NotEmpty().WithMessage("Company code is required")
            .Matches(@"^[A-Z]{2,5}$").WithMessage("Company code must be 2-5 uppercase letters");
    }
}
```

---

## 9. Logging

### 9.1 Logger Injection

```csharp
public class CompanyService
{
    private readonly ILogger<CompanyService> _logger;
    
    public CompanyService(ILogger<CompanyService> logger)
    {
        _logger = logger;
    }
}
```

### 9.2 Log Levels

| Level | Usage |
|-------|-------|
| Trace | Detailed debugging (disabled in production) |
| Debug | Diagnostic information |
| Information | Normal business operations |
| Warning | Recoverable issues |
| Error | Unexpected failures |
| Critical | System-wide failures |

### 9.3 Structured Logging

```csharp
// Correct: Structured logging
_logger.LogInformation("Company {CompanyId} created by {UserId}", company.Id, userId);

// Incorrect: String concatenation
_logger.LogInformation($"Company {company.Id} created by {userId}");
```

---

## 10. Transactions

### 10.1 Transaction Scope

- Use Unit of Work for transaction management
- Keep transactions short
- Don't hold transactions during external calls
- Always rollback on failure

```csharp
public async Task TransferInventoryAsync(TransferRequest request)
{
    await _unitOfWork.BeginTransactionAsync();
    try
    {
        await _unitOfWork.Inventory.DeductAsync(request.FromLocation, request.ProductId, request.Quantity);
        await _unitOfWork.Inventory.AddAsync(request.ToLocation, request.ProductId, request.Quantity);
        await _unitOfWork.CommitAsync();
    }
    catch
    {
        _unitOfWork.Rollback();
        throw;
    }
}
```

### 10.2 Transaction Isolation

- Default: ReadCommitted
- Use explicit isolation level when needed
- Document isolation level requirements

---

## 11. XML Documentation

### 11.1 Public APIs

- Document all public classes, methods, properties
- Include parameter descriptions
- Include return value descriptions
- Include exception documentation

```csharp
/// <summary>
/// Creates a new company in the system.
/// </summary>
/// <param name="request">The company creation request.</param>
/// <returns>The created company with assigned ID.</returns>
/// <exception cref="ValidationException">Thrown when request validation fails.</exception>
/// <exception cref="BusinessException">Thrown when company name already exists.</exception>
public Task<Company> CreateCompanyAsync(CreateCompanyRequest request);
```

### 11.2 Internal Code

- Document complex algorithms
- Document non-obvious business rules
- Document TODO items with work order references

---

## 12. Nullable Reference Types

### 12.1 Configuration

Enable nullable reference types in all projects:

```xml
<PropertyGroup>
    <Nullable>enable</Nullable>
</PropertyGroup>
```

### 12.2 Usage Guidelines

- Use `?` for nullable references
- Initialize non-nullable properties
- Use null-coalescing operators appropriately
- Document null expectations

```csharp
public class Company
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty; // Non-nullable, initialized
    public string? Description { get; set; } // Nullable
}

public Company? FindCompany(int id) // May return null
{
    return _companies.FirstOrDefault(c => c.Id == id);
}
```

---

## 13. Date and Time Handling

### 13.1 UTC Standard

- Store all dates in UTC
- Convert to local time only for display
- Use `DateTime.UtcNow` for current time

```csharp
// Correct
company.CreatedAt = DateTime.UtcNow;
var localTime = company.CreatedAt.ToLocalTime();

// Incorrect
company.CreatedAt = DateTime.Now;
```

### 13.2 DateTimeOffset

- Use `DateTimeOffset` when timezone context matters
- Use `DateTime` for simple date/time storage

### 13.3 Serialization

- Use ISO 8601 format for JSON serialization
- Configure consistent date format across application

---

## 14. Enum Usage

### 14.1 Definition

- Use descriptive enum names
- Use PascalCase for values
- Explicitly assign values for persistence stability

```csharp
public enum OrderStatus
{
    Pending = 1,
    Confirmed = 2,
    Processing = 3,
    Shipped = 4,
    Delivered = 5,
    Cancelled = 6
}
```

### 14.2 Usage

- Use enums instead of magic numbers
- Use switch expressions for enum handling
- Handle all enum cases explicitly

```csharp
var statusText = order.Status switch
{
    OrderStatus.Pending => "Awaiting confirmation",
    OrderStatus.Confirmed => "Order confirmed",
    OrderStatus.Processing => "Being prepared",
    OrderStatus.Shipped => "In transit",
    OrderStatus.Delivered => "Delivered",
    OrderStatus.Cancelled => "Cancelled",
    _ => throw new ArgumentOutOfRangeException(nameof(order.Status), order.Status, null)
};
```

---

## 15. Configuration Management

### 15.1 Configuration Sources

- Use appsettings.json for default configuration
- Use environment variables for environment-specific settings
- Use Azure Key Vault for secrets (when applicable)

### 15.2 Strongly-Typed Configuration

```csharp
public class DatabaseSettings
{
    public string ConnectionString { get; set; } = string.Empty;
    public int CommandTimeout { get; set; } = 30;
    public int MaxRetries { get; set; } = 3;
}

// Registration
services.Configure<DatabaseSettings>(Configuration.GetSection("Database"));

// Usage
public class Repository
{
    private readonly DatabaseSettings _settings;
    
    public Repository(IOptions<DatabaseSettings> options)
    {
        _settings = options.Value;
    }
}
```

### 15.3 Sensitive Data

- Never store secrets in source control
- Use User Secrets for development
- Use Key Vault or similar for production
- Encrypt sensitive configuration values

---

## 16. Code Review Expectations

### 16.1 Pre-Review Checklist

- [ ] Code compiles without warnings
- [ ] All tests pass
- [ ] Code coverage meets minimum (70%)
- [ ] No TODO comments without work order reference
- [ ] XML documentation complete for public APIs
- [ ] Follows naming conventions
- [ ] No hardcoded values
- [ ] Error handling implemented
- [ ] Logging added at appropriate levels

### 16.2 Review Focus Areas

- Architecture compliance
- SOLID principles adherence
- Security considerations
- Performance implications
- Test coverage adequacy
- Code clarity and readability

### 16.3 Review Response Time

- Initial review within 24 hours
- Revision reviews within 12 hours
- Critical fixes reviewed immediately

---

## 17. Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0002 | Architecture Team | Initial definition |

---

*This document is part of the PharmaX Enterprise architectural documentation suite.*
