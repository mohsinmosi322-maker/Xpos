# ADR-0004: Why ADO.NET Instead of Entity Framework

**Status:** Accepted  
**Date:** WO-0002  
**Author:** Architecture Team  
**Deciders:** Architecture Review Board  

---

## Context

PharmaX Enterprise requires a data access strategy that balances productivity, performance, and control with the following requirements:

### Technical Requirements
- Fine-grained control over SQL queries for performance-critical operations
- Support for complex stored procedures
- Explicit transaction management
- Batch operations for high-volume data processing
- Minimal abstraction overhead for POS operations
- Direct access to SQL Server-specific features
- Predictable query execution without ORM magic

### Performance Requirements
- Sub-second response times for POS transactions
- Efficient bulk insert/update operations for inventory
- Optimized read queries for reporting
- Connection pooling and resource management
- Minimal memory footprint

### Operational Requirements
- Query plan optimization and tuning
- Explicit control over connection lifecycle
- Clear visibility into executed SQL
- Easy debugging and profiling
- Support for database-first development

### Compliance Requirements
- Audit trail for all data modifications
- Parameterized queries to prevent SQL injection
- Explicit transaction boundaries
- Deterministic behavior for financial operations

---

## Decision

We will use **ADO.NET with Dapper micro-ORM** as the primary data access technology for PharmaX Enterprise.

### Technology Stack

- **Core Data Access**: ADO.NET (System.Data.SqlClient / Microsoft.Data.SqlClient)
- **Object Mapping**: Dapper (lightweight micro-ORM)
- **Connection Management**: Custom connection factory with pooling
- **Transaction Management**: Explicit TransactionScope and SqlTransaction
- **Query Building**: Parameterized raw SQL with optional builder patterns

### Architecture Integration

```
┌─────────────────────────────────────────┐
│         Application Layer               │
│         (Use Cases, DTOs)               │
├─────────────────────────────────────────┤
│      Infrastructure Layer               │
│  ┌─────────────────────────────────┐   │
│  │        Repositories             │   │
│  │  ┌───────────┐  ┌───────────┐  │   │
│  │  │  Dapper   │  │  ADO.NET  │  │   │
│  │  │  Mapping  │  │  Commands │  │   │
│  │  └───────────┘  └───────────┘  │   │
│  └─────────────────────────────────┘   │
├─────────────────────────────────────────┤
│           SQL Server                    │
└─────────────────────────────────────────┘
```

### Repository Pattern Implementation

```csharp
// Interface defined in Domain/Application
public interface ICompanyRepository
{
    Task<Company?> GetByIdAsync(int id);
    Task<IEnumerable<Company>> GetAllAsync();
    Task<int> CreateAsync(Company company);
    Task UpdateAsync(Company company);
    Task DeleteAsync(int id);
}

// Implementation in Infrastructure using Dapper
public class CompanyRepository : ICompanyRepository
{
    private readonly IDbConnection _connection;
    
    public async Task<Company?> GetByIdAsync(int id)
    {
        const string sql = @"SELECT * FROM Companies WHERE Id = @Id";
        return await _connection.QueryFirstOrDefaultAsync<Company>(sql, new { Id = id });
    }
}
```

---

## Consequences

### Positive

1. **Performance**: Minimal overhead, near-native SQL performance
2. **Control**: Full control over SQL queries and execution
3. **Transparency**: Clear visibility into executed SQL
4. **Stored Procedures**: First-class support for existing procedures
5. **SQL Server Features**: Direct access to all SQL Server capabilities
6. **Simplicity**: Lightweight, easy to understand and debug
7. **Batch Operations**: Efficient bulk operations without ORM complexity
8. **Query Tuning**: Direct query plan optimization possible
9. **No Change Tracking Overhead**: No memory-intensive change tracking
10. **Explicit Transactions**: Clear transaction boundaries

### Negative

1. **More Code**: More boilerplate compared to full ORM
2. **Manual Mapping**: Object-relational mapping must be maintained
3. **No Lazy Loading**: Must explicitly load related data
4. **Schema Changes**: Manual updates required for schema changes
5. **Less Productivity**: Initial development may be slower

### Mitigation Strategies

- Use code generation tools for repetitive CRUD operations
- Create repository base classes for common operations
- Use Dapper's multi-mapping for complex queries
- Implement unit of work pattern for transaction management
- Create SQL templates for common query patterns
- Use SSDT (SQL Server Data Tools) for schema management

---

## Alternatives Considered

### 1. Entity Framework Core

**Description**: Full-featured ORM from Microsoft.

**Rejected Because**:
- Abstraction hides SQL execution details
- Change tracking overhead unnecessary for our use case
- Complex query translation can produce inefficient SQL
- Migration system conflicts with database-first approach
- Learning curve for advanced features
- Debugging complex LINQ queries is difficult
- Bulk operations require extensions or workarounds
- Stored procedure support is second-class

### 2. Entity Framework 6

**Description**: Legacy .NET Framework ORM.

**Rejected Because**:
- All EF Core issues plus:
- No longer actively developed
- .NET Framework only
- Performance inferior to EF Core
- Limited async support

### 3. NHibernate

**Description**: Mature, feature-rich ORM.

**Rejected Because**:
- Steep learning curve
- Complex configuration
- Heavy abstraction layer
- Performance overhead
- XML/Fluent configuration complexity
- Less active development community

### 4. ServiceStack.OrmLite

**Description**: Simple, fast micro-ORM.

**Rejected Because**:
- Less mature than Dapper
- Smaller community
- Fewer features for complex scenarios
- Licensing cost for commercial use

### 5. Pure ADO.NET (No Micro-ORM)

**Description**: Raw ADO.NET without any mapping library.

**Rejected Because**:
- Excessive boilerplate for simple queries
- Manual SqlDataReader mapping is error-prone
- Dapper provides value-add with minimal overhead
- No significant benefit over Dapper approach

---

## Implementation Guidelines

### Connection Management

```csharp
public interface IDbConnectionFactory
{
    IDbConnection CreateConnection();
}

public class SqlConnectionFactory : IDbConnectionFactory
{
    private readonly string _connectionString;
    
    public IDbConnection CreateConnection()
    {
        return new SqlConnection(_connectionString);
    }
}
```

### Repository Base Class

```csharp
public abstract class BaseRepository
{
    protected readonly IDbConnectionFactory _connectionFactory;
    
    protected IDbConnection GetOpenConnection()
    {
        var connection = _connectionFactory.CreateConnection();
        connection.Open();
        return connection;
    }
}
```

### Transaction Management

```csharp
public interface IUnitOfWork : IDisposable
{
    IDbTransaction Transaction { get; }
    void Commit();
    void Rollback();
}

public class UnitOfWork : IUnitOfWork
{
    private readonly IDbConnection _connection;
    private readonly IDbTransaction _transaction;
    private bool _committed;
    
    public IDbTransaction Transaction => _transaction;
    
    public void Commit()
    {
        if (!_committed && _transaction != null)
        {
            _transaction.Commit();
            _committed = true;
        }
    }
    
    public void Rollback()
    {
        if (!_committed && _transaction != null)
        {
            _transaction.Rollback();
        }
    }
    
    public void Dispose()
    {
        if (!_committed)
        {
            Rollback();
        }
        _transaction?.Dispose();
        _connection?.Dispose();
    }
}
```

### Query Patterns

- Use parameterized queries exclusively
- Prefer stored procedures for complex operations
- Use table-valued parameters for batch operations
- Implement pagination at database level
- Use asynchronous methods for all I/O

---

## Performance Considerations

### Optimization Strategies

1. **Connection Pooling**: Leverage built-in SQL Server connection pooling
2. **Async I/O**: Use async/await for all database operations
3. **Batch Operations**: Use table-valued parameters for bulk inserts
4. **Query Caching**: Cache frequently accessed reference data
5. **Index Hints**: Use when query optimizer makes poor choices
6. **Execution Plans**: Monitor and optimize slow queries

### Monitoring

- Log all queries with execution time
- Implement slow query detection
- Track connection pool usage
- Monitor transaction duration
- Profile memory usage

---

## Security Considerations

### SQL Injection Prevention

- Use parameterized queries exclusively
- Never concatenate user input into SQL
- Validate all input before use
- Use stored procedures with parameter validation

### Data Protection

- Encrypt sensitive data at application level
- Use SQL Server Always Encrypted where appropriate
- Implement row-level security in queries
- Audit all data modifications

---

## Future Considerations

1. **Hybrid Approach**: Consider EF Core for read-only reporting queries if beneficial
2. **Code Generation**: Implement T4 templates or source generators for boilerplate
3. **Query Builder**: Develop internal fluent query builder if complexity increases
4. **CQRS**: Separate read/write models may justify different data access strategies

---

## References

- Dapper Documentation: https://github.com/DapperLib/Dapper
- ADO.NET Documentation: https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/
- Microsoft.Data.SqlClient: https://www.nuget.org/packages/Microsoft.Data.SqlClient

---

*This ADR is part of the PharmaX Enterprise architectural decision record suite.*
