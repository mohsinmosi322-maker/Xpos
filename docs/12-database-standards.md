# Database Standards

**Version:** 1.0  
**Document ID:** DB-001  
**Created:** WO-0002  
**Related:** [Repository Standards](./04-repository-standards.md), [Security Architecture](./11-security-architecture.md)

---

## 1. Introduction

This document defines the database standards for PharmaX Enterprise. These standards ensure consistency, performance, security, and maintainability across all database objects.

---

## 2. Database Naming Conventions

### 2.1 General Rules

- Use PascalCase (UpperCamelCase) for all object names
- Use singular nouns for table names
- Avoid spaces and special characters
- Maximum length: 64 characters (SQL Server limit: 128)
- No reserved keywords as names

### 2.2 Object Naming

| Object Type | Convention | Example |
|------------|-----------|---------|
| Tables | Singular noun, PascalCase | `Company`, `Branch`, `User` |
| Columns | PascalCase | `Id`, `CompanyName`, `CreatedAt` |
| Primary Keys | `PK_{TableName}` | `PK_Company` |
| Foreign Keys | `FK_{TableName}_{ReferenceTable}` | `FK_Branch_Company` |
| Indexes | `IX_{TableName}_{Column(s)}` | `IX_User_Username` |
| Unique Constraints | `UQ_{TableName}_{Column}` | `UQ_Company_Code` |
| Default Constraints | `DF_{TableName}_{Column}` | `DF_User_IsActive` |
| Check Constraints | `CK_{TableName}_{Purpose}` | `CK_Product_Price_Positive` |
| Stored Procedures | `usp_{Action}_{Entity}` | `usp_GetCompanyById` |
| Functions | `fn_{Purpose}` | `fn_FormatPhoneNumber` |
| Views | `vw_{Description}` | `vw_ActiveUsers` |
| Triggers | `trg_{Table}_{Event}` | `trg_User_AfterUpdate` |

### 2.3 Column Naming Standards

| Column Type | Name | Data Type | Notes |
|------------|------|-----------|-------|
| Primary Key | `Id` | INT | Identity column |
| Foreign Key | `{ReferenceTable}Id` | INT | Matches referenced PK |
| Created Timestamp | `CreatedAt` | DATETIME2(7) | UTC time |
| Modified Timestamp | `ModifiedAt` | DATETIME2(7) | UTC time, nullable |
| Created By | `CreatedBy` | INT | User Id |
| Modified By | `ModifiedBy` | INT | User Id, nullable |
| Is Deleted | `IsDeleted` | BIT | Soft delete flag |
| Version | `RowVersion` | ROWVERSION | Optimistic concurrency |

### 2.4 Example Table Definition

```sql
CREATE TABLE Company (
    Id INT IDENTITY(1,1) NOT NULL,
    Code NVARCHAR(10) NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    TaxId NVARCHAR(20) NULL,
    Email NVARCHAR(100) NULL,
    Phone NVARCHAR(20) NULL,
    Address NVARCHAR(500) NULL,
    City NVARCHAR(50) NULL,
    State NVARCHAR(50) NULL,
    PostalCode NVARCHAR(10) NULL,
    Country NVARCHAR(50) NOT NULL DEFAULT 'Pakistan',
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt DATETIME2(7) NULL,
    CreatedBy INT NOT NULL,
    ModifiedBy INT NULL,
    RowVersion ROWVERSION NOT NULL,
    
    CONSTRAINT PK_Company PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT UQ_Company_Code UNIQUE (Code),
    CONSTRAINT UQ_Company_Name UNIQUE (Name),
    CONSTRAINT CK_Company_Code_Format CHECK (Code LIKE '[A-Z][A-Z][A-Z]%')
);
```

---

## 3. Primary Key Strategy

### 3.1 Key Type Selection

| Scenario | Key Type | Rationale |
|----------|----------|-----------|
| Standard tables | INT IDENTITY | Simple, efficient, familiar |
| High-volume tables (>2B rows) | BIGINT IDENTITY | Prevent overflow |
| Distributed systems (future) | UNIQUEIDENTIFIER | GUID for global uniqueness |
| Natural keys | As appropriate | When business key is stable |

### 3.2 Identity Configuration

```sql
-- Standard identity column
Id INT IDENTITY(1,1) NOT NULL

-- With specific seed/increment
Id INT IDENTITY(1000,1) NOT NULL

-- For high-volume tables
Id BIGINT IDENTITY(1,1) NOT NULL
```

### 3.3 Composite Keys

Avoid composite primary keys when possible. If required:

```sql
CREATE TABLE UserRole (
    UserId INT NOT NULL,
    RoleId INT NOT NULL,
    AssignedAt DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    
    CONSTRAINT PK_UserRole PRIMARY KEY CLUSTERED (UserId, RoleId),
    CONSTRAINT FK_UserRole_User FOREIGN KEY (UserId) REFERENCES User(Id),
    CONSTRAINT FK_UserRole_Role FOREIGN KEY (RoleId) REFERENCES Role(Id)
);
```

---

## 4. Foreign Key Conventions

### 4.1 Naming

```sql
CONSTRAINT FK_{ChildTable}_{ParentTable} 
    FOREIGN KEY ({ChildColumn}) 
    REFERENCES {ParentTable}({ParentColumn})
```

### 4.2 Referential Integrity

- All relationships must have foreign key constraints
- Use ON DELETE/UPDATE appropriately
- Document cascading behavior

```sql
-- Cascade delete (use sparingly)
ON DELETE CASCADE

-- Set null on delete
ON DELETE SET NULL

-- Restrict delete (default)
-- No action specified
```

### 4.3 Indexing Foreign Keys

Always create index on foreign key columns:

```sql
CREATE INDEX IX_Branch_CompanyId ON Branch(CompanyId);
```

---

## 5. Indexing Strategy

### 5.1 Index Types

| Type | Purpose | Usage |
|------|---------|-------|
| Clustered | Physical row ordering | One per table (usually PK) |
| Non-clustered | Query optimization | Multiple per table |
| Unique | Enforce uniqueness | Business keys |
| Filtered | Subset of rows | Active records, soft deletes |
| Covering | Include additional columns | Frequently accessed data |

### 5.2 Standard Indexes

Create indexes for:

1. **Primary Keys**: Automatic clustered index
2. **Foreign Keys**: Improve join performance
3. **Search Columns**: Columns used in WHERE clauses
4. **Sort Columns**: Columns used in ORDER BY
5. **Unique Constraints**: Automatic unique index

### 5.3 Index Naming

```sql
-- Single column
CREATE INDEX IX_User_Username ON User(Username);

-- Multiple columns (order matters)
CREATE INDEX IX_Order_CustomerDate ON Order(CustomerId, OrderDate DESC);

-- Filtered index
CREATE INDEX IX_Product_Active ON Product(Id, Name) WHERE IsDeleted = 0;

-- Unique index
CREATE UNIQUE INDEX IX_User_Email ON User(Email) WHERE IsDeleted = 0;
```

### 5.4 Index Guidelines

- Limit indexes to 5-6 per table (balance read/write performance)
- Keep index keys narrow (reduce storage, improve cache)
- Consider INCLUDE columns for covering indexes
- Monitor unused indexes and remove them
- Rebuild/reorganize indexes based on fragmentation

---

## 6. Audit Columns

### 6.1 Required Audit Columns

Every business table must include:

```sql
-- Creation tracking
CreatedAt DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
CreatedBy INT NOT NULL,

-- Modification tracking
ModifiedAt DATETIME2(7) NULL,
ModifiedBy INT NULL,

-- Soft delete
IsDeleted BIT NOT NULL DEFAULT 0,

-- Concurrency
RowVersion ROWVERSION NOT NULL
```

### 6.2 Trigger-Based Audit Trail

For detailed audit history:

```sql
CREATE TABLE CompanyAudit (
    AuditId BIGINT IDENTITY(1,1) NOT NULL,
    CompanyId INT NOT NULL,
    Action NVARCHAR(10) NOT NULL,  -- INSERT, UPDATE, DELETE
    ChangedAt DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    ChangedBy INT NOT NULL,
    OldValues NVARCHAR(MAX) NULL,  -- JSON
    NewValues NVARCHAR(MAX) NULL,  -- JSON
    
    CONSTRAINT PK_CompanyAudit PRIMARY KEY CLUSTERED (AuditId)
);
```

### 6.3 Temporal Tables (SQL Server 2016+)

For automatic history tracking:

```sql
CREATE TABLE Company (
    Id INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    -- ... other columns
    SysStartTime DATETIME2(7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    SysEndTime DATETIME2(7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CompanyHistory));
```

---

## 7. Soft Delete Policy

### 7.1 Implementation

All business tables use soft delete:

```sql
IsDeleted BIT NOT NULL DEFAULT 0
```

### 7.2 Query Patterns

Always filter out deleted records:

```sql
-- Correct
SELECT * FROM Company WHERE IsDeleted = 0;

-- Incorrect (exposes deleted records)
SELECT * FROM Company;
```

### 7.3 Unique Constraints with Soft Delete

Include IsDeleted in unique constraint:

```sql
CREATE UNIQUE INDEX UQ_Company_Code 
    ON Company(Code) 
    WHERE IsDeleted = 0;
```

### 7.4 Hard Delete

Hard deletes only for:
- Data cleanup (archived records)
- Regulatory requirements (right to be forgotten)
- Test data removal

---

## 8. Optimistic Concurrency Strategy

### 8.1 RowVersion Implementation

```sql
CREATE TABLE Company (
    Id INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    RowVersion ROWVERSION NOT NULL,
    
    CONSTRAINT PK_Company PRIMARY KEY (Id)
);
```

### 8.2 Update Pattern

```csharp
public async Task UpdateAsync(Company company)
{
    const string sql = @"
        UPDATE Company 
        SET Name = @Name,
            ModifiedAt = SYSUTCDATETIME(),
            ModifiedBy = @ModifiedBy
        WHERE Id = @Id 
          AND RowVersion = @OriginalRowVersion";
    
    var rowsAffected = await _connection.ExecuteAsync(sql, new
    {
        company.Name,
        company.ModifiedBy,
        company.Id,
        OriginalRowVersion = company.OriginalRowVersion
    });
    
    if (rowsAffected == 0)
        throw new ConcurrencyException("Company", company.Id);
}
```

### 8.3 SQL Server ROWVERSION

- Automatically increments on any row modification
- 8-byte binary number
- Not persistent across server restarts
- Use for concurrency checking only, not as identifier

---

## 9. Transaction Guidelines

### 9.1 Transaction Scope

- Keep transactions short
- Don't hold transactions during user interaction
- Don't hold transactions during external service calls
- Use appropriate isolation levels

### 9.2 Isolation Levels

| Level | Use Case | Notes |
|-------|----------|-------|
| ReadCommitted | Default | Most operations |
| ReadUncommitted | Reporting | Dirty reads acceptable |
| RepeatableRead | Complex reads | Prevent phantom reads |
| Serializable | Critical consistency | Highest isolation |
| Snapshot | High concurrency | Row versioning |

### 9.3 Explicit Transaction Pattern

```csharp
public async Task TransferInventoryAsync(TransferRequest request)
{
    using var connection = _connectionFactory.CreateConnection();
    await connection.OpenAsync();
    
    using var transaction = connection.BeginTransaction(IsolationLevel.ReadCommitted);
    try
    {
        await DeductInventoryAsync(connection, transaction, request.FromLocation, request.ProductId, request.Quantity);
        await AddInventoryAsync(connection, transaction, request.ToLocation, request.ProductId, request.Quantity);
        await LogTransferAsync(connection, transaction, request);
        
        transaction.Commit();
    }
    catch
    {
        transaction.Rollback();
        throw;
    }
}
```

---

## 10. SQL Coding Standards

### 10.1 Formatting

```sql
-- Keywords in uppercase
SELECT 
    c.Id,
    c.Name,
    c.Code
FROM Company c
INNER JOIN Branch b ON b.CompanyId = c.Id
WHERE c.IsDeleted = 0
    AND c.IsActive = 1
ORDER BY c.Name;
```

### 10.2 Parameterized Queries

```sql
-- Correct: Parameterized
SELECT * FROM Company WHERE Id = @Id;

-- Incorrect: String concatenation (SQL injection risk)
SELECT * FROM Company WHERE Id = ' + @Id + ';
```

### 10.3 Stored Procedure Template

```sql
CREATE PROCEDURE usp_GetCompanyById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.Id,
        c.Code,
        c.Name,
        c.TaxId,
        c.Email,
        c.Phone,
        c.Address,
        c.City,
        c.State,
        c.PostalCode,
        c.Country,
        c.IsActive,
        c.CreatedAt,
        c.CreatedBy,
        c.ModifiedAt,
        c.ModifiedBy
    FROM Company c
    WHERE c.Id = @Id
        AND c.IsDeleted = 0;
END;
```

### 10.4 Error Handling in T-SQL

```sql
CREATE PROCEDURE usp_CreateCompany
    @Code NVARCHAR(10),
    @Name NVARCHAR(100),
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Company (Code, Name, CreatedBy)
        VALUES (@Code, @Name, @CreatedBy);
        
        DECLARE @NewId INT = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        SELECT @NewId AS Id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    END CATCH;
END;
```

---

## 11. Data Types

### 11.1 Common Data Types

| Purpose | Data Type | Notes |
|---------|-----------|-------|
| Integer ID | INT | Up to 2 billion rows |
| Large ID | BIGINT | Over 2 billion rows |
| Short text | NVARCHAR(50) | Names, codes |
| Medium text | NVARCHAR(100-255) | Descriptions |
| Long text | NVARCHAR(MAX) | Notes, comments |
| Boolean | BIT | 0/1 values |
| Date/Time | DATETIME2(7) | Precision to 100ns |
| Money | DECIMAL(18,4) | Financial amounts |
| Quantity | DECIMAL(18,6) | Measurements |
| Percentage | DECIMAL(5,2) | 0-100 with 2 decimals |

### 11.2 String Length Guidelines

| Field | Recommended Length |
|-------|-------------------|
| Code | 10-20 |
| Name | 50-100 |
| Email | 100 |
| Phone | 20 |
| Address Line | 100 |
| City | 50 |
| State/Province | 50 |
| Postal Code | 10 |
| Country | 50 |
| Description | 255-500 |

---

## 12. Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0002 | Architecture Team | Initial definition |

---

*This document is part of the PharmaX Enterprise architectural documentation suite.*
