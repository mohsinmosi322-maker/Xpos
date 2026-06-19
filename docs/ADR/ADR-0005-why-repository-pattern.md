# ADR-0005: Why Repository Pattern + Unit of Work

**Status:** Accepted  
**Date:** WO-0002  
**Author:** Architecture Team  
**Deciders:** Architecture Review Board  

---

## Context

PharmaX Enterprise requires a data access abstraction strategy that provides:

### Technical Requirements
- Decoupling between business logic and data access implementation
- Testability of application services without database dependencies
- Consistent data access patterns across all modules
- Transaction management across multiple repositories
- Support for multiple data sources (primary DB, cache, external APIs)
- Flexibility to change data access technology without affecting business logic

### Architectural Requirements
- Clean Architecture compliance (dependency rule)
- Single Responsibility Principle adherence
- Interface segregation for different access patterns
- Clear separation of read and write operations (future CQRS)

### Operational Requirements
- Easy mocking for unit tests
- Consistent error handling
- Centralized connection management
- Audit logging integration point
- Performance monitoring hooks

---

## Decision

We will implement the **Repository Pattern combined with Unit of Work pattern** for data access abstraction in PharmaX Enterprise.

### Pattern Definitions

**Repository Pattern**: Mediates between the domain and data mapping layers using a collection-like interface for accessing domain objects.

**Unit of Work Pattern**: Maintains a list of objects affected by a business transaction and coordinates the writing out of changes.

### Architecture Integration

```
┌─────────────────────────────────────────┐
│         Application Layer               │
│  ┌─────────────────────────────────┐   │
│  │      Application Services       │   │
│  │  Depends on Interfaces Only     │   │
│  └─────────────────────────────────┘   │
├─────────────────────────────────────────┤
│           Domain Layer                  │
│  ┌─────────────────────────────────┐   │
│  │   IRepository<T> Interfaces     │   │
│  │   IUnitOfWork Interface         │   │
│  └─────────────────────────────────┘   │
├─────────────────────────────────────────┤
│      Infrastructure Layer               │
│  ┌─────────────────────────────────┐   │
│  │   Repository Implementations    │   │
│  │   UnitOfWork Implementation     │   │
│  │   (ADO.NET + Dapper)            │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### Interface Design

```csharp
// Generic Repository Interface
public interface IRepository<T> where T : class, IEntity
{
    Task<T?> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<IEnumerable<T>> FindAsync(ISpecification<T> specification);
    Task<int> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
    Task<bool> ExistsAsync(int id);
}

// Unit of Work Interface
public interface IUnitOfWork : IDisposable
{
    ICompanyRepository Companies { get; }
    IBranchRepository Branches { get; }
    IUserRepository Users { get; }
    
    IDbTransaction Transaction { get; }
    Task<int> CommitAsync(CancellationToken cancellationToken = default);
    void Rollback();
}

// Specialized Repository Interfaces
public interface ICompanyRepository : IRepository<Company>
{
    Task<Company?> GetWithBranchesAsync(int id);
    Task<IEnumerable<Company>> SearchByNameAsync(string searchTerm);
    Task<bool> IsNameUniqueAsync(string name, int? excludeId = null);
}
```

### Implementation Structure

```
PharmaX.Infrastructure/
├── Data/
│   ├── ConnectionFactory.cs
│   └── UnitOfWork.cs
├── Repositories/
│   ├── BaseRepository.cs
│   ├── CompanyRepository.cs
│   ├── BranchRepository.cs
│   └── ...
└── Interfaces/
    ├── ICompanyRepository.cs
    ├── IBranchRepository.cs
    └── ...
```

---

## Consequences

### Positive

1. **Testability**: Application services can be tested with mocked repositories
2. **Decoupling**: Business logic independent of data access technology
3. **Consistency**: Uniform data access patterns across the codebase
4. **Maintainability**: Changes to data access don't affect business logic
5. **Transaction Management**: Clear transaction boundaries via Unit of Work
6. **Single Responsibility**: Each repository handles one aggregate root
7. **Flexibility**: Easy to swap data access implementations
8. **CQRS Ready**: Natural separation for read/write models
9. **Audit Integration**: Central point for audit logging
10. **Performance**: Can optimize per-repository without affecting others

### Negative

1. **Abstraction Overhead**: Additional layer between business logic and database
2. **Boilerplate Code**: More interfaces and classes to maintain
3. **Learning Curve**: Team must understand both patterns
4. **Potential Over-engineering**: May be excessive for simple CRUD operations
5. **Leaky Abstractions**: Complex queries may require breaking the pattern

### Mitigation Strategies

- Create generic base repository to reduce duplication
- Use code generation for standard CRUD repositories
- Allow direct data access for complex reporting queries
- Document when to break the pattern (and how to do it safely)
- Provide clear examples and templates

---

## Alternatives Considered

### 1. Active Record Pattern

**Description**: Entities contain their own data access logic.

**Rejected Because**:
- Violates Single Responsibility Principle
- Entities coupled to database
- Difficult to test without database
- Violates Clean Architecture dependency rule
- Hard to change data access strategy

### 2. Data Mapper Pattern Only (No Repository)

**Description**: Direct use of ORM/ mapper without repository abstraction.

**Rejected Because**:
- Business logic still aware of data access patterns
- Less control over queries
- Harder to implement caching strategies
- No clear transaction boundary abstraction

### 3. Query Object Pattern Only

**Description**: Encapsulate queries in objects without repository.

**Rejected Because**:
- Doesn't solve write operation abstraction
- Still need repository for command operations
- Can be combined with Repository (future enhancement)

### 4. CQRS from Start

**Description**: Separate repositories for reads and writes.

**Rejected Because**:
- Adds complexity before needed
- Most operations are simple CRUD
- Can evolve to CQRS when requirements demand
- Repository pattern supports future CQRS transition

### 5. No Pattern (Direct Data Access)

**Description**: Inject connection factory directly into services.

**Rejected Because**:
- Business logic coupled to SQL
- Impossible to test without database
- No abstraction for changing data access
- Violates Clean Architecture principles

---

## Implementation Guidelines

### Repository Rules

1. **One Repository Per Aggregate Root**: Don't create repositories for child entities
2. **Return Domain Entities**: Repositories return domain objects, not DTOs
3. **No Business Logic**: Repositories contain no business rules
4. **Async by Default**: All methods asynchronous
5. **Specification Pattern**: Use for complex queries
6. **No Tracking**: Repositories don't track entity state (unlike EF)

### Unit of Work Rules

1. **Single Transaction**: One transaction per unit of work
2. **Explicit Commit**: Caller must explicitly commit
3. **Automatic Rollback**: Rollback on dispose if not committed
4. **Repository Scope**: Repositories share same connection/transaction
5. **Short-Lived**: Unit of work should be short-lived

### Example Usage

```csharp
public class CreateCompanyService
{
    private readonly IUnitOfWork _unitOfWork;
    
    public async Task<Company> CreateCompanyAsync(CreateCompanyRequest request)
    {
        // Validate business rules
        var exists = await _unitOfWork.Companies.IsNameUniqueAsync(request.Name);
        if (!exists)
            throw new BusinessException("Company name already exists");
        
        // Create entity
        var company = new Company
        {
            Name = request.Name,
            Code = request.Code,
            // ...
        };
        
        // Persist
        var id = await _unitOfWork.Companies.AddAsync(company);
        await _unitOfWork.CommitAsync();
        
        company.Id = id;
        return company;
    }
}
```

### Testing with Mocks

```csharp
[Fact]
public async Task CreateCompany_ShouldThrow_WhenNameExists()
{
    // Arrange
    var mockRepo = new Mock<ICompanyRepository>();
    mockRepo.Setup(r => r.IsNameUniqueAsync(It.IsAny<string>()))
            .ReturnsAsync(false);
    
    var mockUow = new Mock<IUnitOfWork>();
    mockUow.Setup(u => u.Companies).Returns(mockRepo.Object);
    
    var service = new CreateCompanyService(mockUow.Object);
    
    // Act & Assert
    await Assert.ThrowsAsync<BusinessException>(
        () => service.CreateCompanyAsync(new CreateCompanyRequest()));
}
```

---

## Transaction Management

### Transaction Boundaries

```csharp
public interface IUnitOfWork : IDisposable
{
    Task BeginTransactionAsync(IsolationLevel isolationLevel = IsolationLevel.ReadCommitted);
    Task<int> CommitAsync(CancellationToken cancellationToken = default);
    void Rollback();
}
```

### Usage Patterns

**Single Operation**:
```csharp
await _unitOfWork.Companies.AddAsync(company);
await _unitOfWork.CommitAsync();
```

**Multiple Operations**:
```csharp
await _unitOfWork.BeginTransactionAsync();
try
{
    await _unitOfWork.Companies.AddAsync(company);
    await _unitOfWork.Branches.AddAsync(branch);
    await _unitOfWork.Users.AddAsync(user);
    await _unitOfWork.CommitAsync();
}
catch
{
    _unitOfWork.Rollback();
    throw;
}
```

---

## Performance Considerations

### Optimization Strategies

1. **Connection Sharing**: All repositories share single connection per UoW
2. **Batch Operations**: Implement batch methods on repositories when needed
3. **Caching**: Add caching layer in repository implementations
4. **Read-Only Short-Circuit**: Skip transaction for read-only operations
5. **Lazy Loading**: Not supported; explicit loading required

### Monitoring

- Track repository method execution times
- Monitor transaction duration
- Log connection usage patterns
- Profile memory allocation per repository call

---

## Future Considerations

1. **CQRS Evolution**: Split repositories into Command and Query sides
2. **Event Sourcing**: Repository pattern supports event sourcing transition
3. **Multi-Database**: Unit of Work can coordinate multiple databases
4. **Saga Pattern**: For distributed transactions across services

---

## References

- "Patterns of Enterprise Application Architecture" by Martin Fowler
- Microsoft Repository Pattern Guide: https://docs.microsoft.com/en-us/dotnet/architecture/
- Unit of Work Pattern: https://martinfowler.com/eaaCatalog/unitOfWork.html

---

*This ADR is part of the PharmaX Enterprise architectural decision record suite.*
