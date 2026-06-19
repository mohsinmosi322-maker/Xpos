# Enterprise Database Architecture

## PharmaX Enterprise Platform

**Version:** 1.0  
**Document ID:** DBA-001  
**Created:** WO-0003  
**Status:** Approved  

---

## Overview

This document defines the SQL Server database architecture for the PharmaX Enterprise platform. The design supports:

- Single pharmacy deployments
- Multi-branch enterprise operations
- Future centralized ERP architecture
- Regulatory compliance requirements
- High availability and disaster recovery

The architecture follows principles established in:
- [Canonical Data Model](13-canonical-data-model.md)
- [Database Standards](12-database-standards.md)
- ADR-0003: Why SQL Server
- ADR-0004: Why ADO.NET instead of Entity Framework

---

## Design Principles

1. **Normalized Design**: Third Normal Form (3NF) as baseline
2. **Auditability**: Every table includes audit columns
3. **Soft Deletes**: No hard deletes on business entities
4. **Referential Integrity**: Foreign key constraints enforced
5. **Performance**: Strategic indexing without over-indexing
6. **Scalability**: Partition-ready design for large tables
7. **Security**: Principle of least privilege at database level

---

# Database Layout

## Single Database Strategy

PharmaX uses a **single database per company** strategy with schema-based separation:

```
PharmaXDB
├── Schema: core          (Organization, Security)
├── Schema: product       (Product Catalog)
├── Schema: inventory     (Stock Management)
├── Schema: purchasing    (Procurement)
├── Schema: sales         (POS, Orders)
├── Schema: finance       (Ledgers, Payments)
├── Schema: reference     (Lookup tables, Codes)
└── Schema: audit         (Audit logs, History)
```

### Rationale

| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| Single DB, Multiple Schemas | Simple deployment, easy queries, consistent backups | Large database size over time | ✅ Selected |
| Database per Branch | Isolation, independent backups | Complex reporting, cross-branch transactions difficult | ❌ Rejected |
| Database per Company | Multi-tenant isolation | Reporting across companies requires federation | Future consideration |
| Sharded by Branch | Horizontal scalability | Application complexity, distributed transactions | ❌ Over-engineering |

### Future Multi-Company Support

For enterprise deployments with multiple legal entities:
- Option A: Separate database per company (application-level federation)
- Option B: Single database with CompanyId partitioning
- Decision deferred until multi-company requirement confirmed

---

# Schema Definitions

## core Schema

**Purpose**: Organization structure and security entities.

**Tables**:
- `core.Companies`
- `core.Branches`
- `core.Warehouses`
- `core.Counters`
- `core.CashDrawers`
- `core.Users`
- `core.Roles`
- `core.Permissions`
- `core.UserRoles`
- `core.RolePermissions`
- `core.Sessions`

---

## product Schema

**Purpose**: Product catalog and classification.

**Tables**:
- `product.Categories`
- `product.Manufacturers`
- `product.Generics`
- `product.Brands`
- `product.Units`
- `product.Products`
- `product.ProductVariants`
- `product.ProductBarcodes`
- `product.ProductTaxes`

---

## inventory Schema

**Purpose**: Stock management and tracking.

**Tables**:
- `inventory.InventoryItems`
- `inventory.StockLedger`
- `inventory.StockMovements`
- `inventory.Adjustments`
- `inventory.AdjustmentLines`
- `inventory.Transfers`
- `inventory.TransferLines`
- `inventory.Damages`
- `inventory.DamageLines`

---

## purchasing Schema

**Purpose**: Procurement and supplier management.

**Tables**:
- `purchasing.Suppliers`
- `purchasing.PurchaseOrders`
- `purchasing.PurchaseOrderLines`
- `purchasing.GoodsReceipts`
- `purchasing.GoodsReceiptLines`
- `purchasing.PurchaseInvoices`
- `purchasing.PurchaseInvoiceLines`
- `purchasing.SupplierReturns`
- `purchasing.SupplierReturnLines`

---

## sales Schema

**Purpose**: Sales transactions and customer management.

**Tables**:
- `sales.Customers`
- `sales.SalesOrders`
- `sales.SalesOrderLines`
- `sales.SalesInvoices`
- `sales.SalesInvoiceLines`
- `sales.SalesReturns`
- `sales.SalesReturnLines`
- `sales.Payments`
- `sales.PaymentAllocations`

---

## finance Schema

**Purpose**: Financial records and ledgers.

**Tables**:
- `finance.CashBooks`
- `finance.BankBooks`
- `finance.Expenses`
- `finance.Incomes`
- `finance.CustomerLedger`
- `finance.SupplierLedger`
- `finance.TaxRates`
- `finance.FiscalPeriods`

---

## reference Schema

**Purpose**: Lookup tables and system codes.

**Tables**:
- `reference.StatusTypes`
- `reference.DocumentTypes`
- `reference.ReasonCodes`
- `reference.CountryCodes`
- `reference.CurrencyCodes`
- `reference.UomConversions`

---

## audit Schema

**Purpose**: Audit trail and historical data.

**Tables**:
- `audit.DataChangeLog`
- `audit.LoginHistory`
- `audit.ActivityLog`
- `audit.SessionHistory`

---

# Naming Conventions

## General Rules

| Element | Convention | Example |
|---------|------------|---------|
| Schema | lowercase, singular | `core`, `product` |
| Table | PascalCase, plural | `Companies`, `SalesOrders` |
| Column | PascalCase, descriptive | `CompanyName`, `OrderDate` |
| Primary Key | `PK_{Table}` | `PK_Companies` |
| Foreign Key | `FK_{Table}_{Reference}` | `FK_Branches_Companies` |
| Index | `IX_{Table}_{Columns}` | `IX_Users_Username` |
| Unique Constraint | `UQ_{Table}_{Column}` | `UQ_Users_Email` |
| Check Constraint | `CK_{Table}_{Column}` | `CK_Products_Price_Positive` |
| Default Constraint | `DF_{Table}_{Column}` | `DF_Companies_CreatedDate` |

## Column Naming Standards

| Column Type | Naming Pattern | Example |
|-------------|----------------|---------|
| Primary Key | `Id` | `Id` |
| Foreign Key | `{Reference}Id` | `CompanyId`, `BranchId` |
| Date/Time | `{Event}Date` or `{Event}DateTime` | `CreatedDate`, `OrderDate` |
| Amount | `{Description}Amount` | `TotalAmount`, `TaxAmount` |
| Quantity | `{Description}Quantity` | `OrderQuantity`, `ReceivedQuantity` |
| Rate | `{Description}Rate` | `TaxRate`, `DiscountRate` |
| Flag/Boolean | `Is{State}` or `Has{Feature}` | `IsActive`, `IsDeleted` |
| Code | `{Entity}Code` | `CompanyCode`, `ProductCode` |

## Audit Columns (Standard on All Tables)

```sql
CreatedBy        INT          NOT NULL
CreatedDate      DATETIME2(0) NOT NULL CONSTRAINT DF_{Table}_CreatedDate DEFAULT SYSUTCDATETIME()
ModifiedBy       INT          NULL
ModifiedDate     DATETIME2(0) NULL
IsDeleted        BIT          NOT NULL CONSTRAINT DF_{Table}_IsDeleted DEFAULT 0
DeletedBy        INT          NULL
DeletedDate      DATETIME2(0) NULL
RowVersion       ROWVERSION   NOT NULL
```

---

# Key Strategy

## Primary Keys

**Strategy**: `BIGINT IDENTITY(1,1)` for all tables.

### Rationale

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| INT IDENTITY | Smaller size, familiar | Limited to 2.1B rows | ❌ Insufficient for ledger tables |
| BIGINT IDENTITY | Supports 9 quintillion rows, simple | Slightly larger than INT | ✅ Selected |
| UNIQUEIDENTIFIER (GUID) | Globally unique, merge-friendly | Larger (16 bytes), index fragmentation | ❌ Not needed for single-DB |
| Composite Keys | Natural key enforcement | Complex foreign keys, wider indexes | ❌ Surrogate keys preferred |

### Exceptions

- **Lookup/Reference tables**: May use small INT with manual codes for readability
- **Association tables**: Composite key acceptable if no additional attributes

---

## Foreign Keys

**Strategy**: Match primary key type (`BIGINT`) with explicit constraint naming.

### Rules

1. All foreign keys must be named explicitly
2. Foreign key columns must match referenced column type exactly
3. Cascade delete used sparingly (see Constraint Strategy)
4. Foreign keys indexed when not part of leading index position

---

# Constraint Strategy

## Primary Key Constraints

- Every table must have a primary key
- Named: `PK_{TableName}`
- Typically clustered (see Index Strategy)

---

## Foreign Key Constraints

- Enforce referential integrity on all relationships
- Named: `FK_{TableName}_{ReferenceTableName}`
- Action on delete:
  - `NO ACTION` (default) for most business tables
  - `CASCADE` only for child records that cannot exist independently
- Action on update: `NO ACTION` (primary keys never updated)

### Cascade Delete Policy

| Relationship Type | On Delete | Rationale |
|-------------------|-----------|-----------|
| Company → Branch | CASCADE | Branches cannot exist without company |
| Branch → Counter | CASCADE | Counters are branch-specific |
| User → Session | CASCADE | Sessions orphaned on user deletion |
| Order → OrderLines | CASCADE | Lines meaningless without header |
| Product → Inventory | NO ACTION | Prevent accidental data loss |
| Customer → SalesOrder | NO ACTION | Preserve history |

---

## Unique Constraints

- Business keys enforced via unique constraints
- Named: `UQ_{TableName}_{ColumnName}`
- Allow NULLs unless business rule requires NOT NULL

### Examples

```sql
-- Username unique within company
ALTER TABLE core.Users 
ADD CONSTRAINT UQ_Users_Company_Username 
UNIQUE (CompanyId, Username);

-- Email unique globally
ALTER TABLE core.Users 
ADD CONSTRAINT UQ_Users_Email 
UNIQUE (Email);

-- Product SKU unique within company
ALTER TABLE product.Products 
ADD CONSTRAINT UQ_Products_Company_SKU 
UNIQUE (CompanyId, SKU);

-- Barcode unique globally
ALTER TABLE product.ProductBarcodes 
ADD CONSTRAINT UQ_ProductBarcodes_Code 
UNIQUE (Barcode);
```

---

## Check Constraints

- Business rules enforced at database level
- Named: `CK_{TableName}_{RuleDescription}`
- Used for data validation that doesn't change

### Standard Check Constraints

```sql
-- Positive prices
ALTER TABLE product.Products
ADD CONSTRAINT CK_Products_Price_Positive
CHECK (Price >= 0);

-- Quantity cannot be negative
ALTER TABLE inventory.InventoryItems
ADD CONSTRAINT CK_InventoryItems_Quantity_NonNegative
CHECK (QuantityOnHand >= 0);

-- Date ranges
ALTER TABLE sales.SalesOrders
ADD CONSTRAINT CK_SalesOrders_Date_Valid
CHECK (OrderDate <= COALESCE(ShippedDate, OrderDate));

-- Status values
ALTER TABLE core.Users
ADD CONSTRAINT CK_Users_Status_Valid
CHECK (Status IN ('Active', 'Suspended', 'Terminated', 'Locked'));

-- Percentage range
ALTER TABLE sales.SalesOrderLines
ADD CONSTRAINT CK_SalesOrderLines_Discount_Range
CHECK (DiscountRate BETWEEN 0 AND 100);
```

---

## Default Constraints

- Consistent defaults across tables
- Named: `DF_{TableName}_{ColumnName}`

### Standard Defaults

```sql
-- Boolean flags
DEFAULT 0 for IsDeleted, IsActive, IsProcessed

-- Dates
DEFAULT SYSUTCDATETIME() for CreatedDate

-- Status
DEFAULT 'Draft' for Status columns where applicable

-- Numeric
DEFAULT 0 for Quantity, Amount columns (when appropriate)
```

---

# Index Strategy

## Clustered Index Policy

**Default**: Primary key is the clustered index.

### Rationale

- Most queries filter or join on primary key
- Insert order typically matches identity column
- Simplifies foreign key relationships

### Exceptions

| Table Type | Clustered Index | Rationale |
|------------|-----------------|-----------|
| Ledger tables | `(CompanyId, TransactionDate, Id)` | Time-series queries common |
| Detail tables | `(HeaderId, Id)` | Master-detail patterns |
| Many-to-many | Composite key | No separate identity needed |

---

## Non-Clustered Index Policy

**Principle**: Index based on query patterns, not just foreign keys.

### Index Categories

1. **Foreign Key Indexes**: Automatically created for FK columns
2. **Filter Indexes**: Common WHERE clause columns
3. **Covering Indexes**: Include frequently selected columns
4. **Unique Indexes**: Enforce business uniqueness

### Standard Indexes by Table Type

#### Master Tables (Company, Branch, User, etc.)

```sql
-- Status filtering
CREATE INDEX IX_{Table}_Status ON {Table}(Status) WHERE IsDeleted = 0;

-- Code lookups
CREATE UNIQUE INDEX IX_{Table}_Code ON {Table}(CompanyId, Code) WHERE IsDeleted = 0;
```

#### Transaction Tables (Orders, Invoices)

```sql
-- Date range queries
CREATE INDEX IX_{Table}_Date ON {Table}(CompanyId, OrderDate) 
WHERE IsDeleted = 0;

-- Status filtering
CREATE INDEX IX_{Table}_Status ON {Table}(CompanyId, Status) 
WHERE IsDeleted = 0;

-- Customer/Supplier lookups
CREATE INDEX IX_{Table}_Party ON {Table}(CompanyId, CustomerId, OrderDate) 
WHERE IsDeleted = 0;
```

#### Detail Tables (Order Lines, Invoice Lines)

```sql
-- Header lookup
CREATE INDEX IX_{Table}_Header ON {Table}(OrderId);

-- Product analysis
CREATE INDEX IX_{Table}_Product ON {Table}(ProductId, OrderDate);
```

#### Ledger Tables

```sql
-- Account lookups
CREATE INDEX IX_{Table}_Account ON {Table}(AccountId, TransactionDate);

-- Document reference
CREATE INDEX IX_{Table}_Document ON {Table}(DocumentType, DocumentId);

-- Balance calculation
CREATE INDEX IX_{Table}_Balance ON {Table}(AccountId, TransactionDate, Id);
```

---

## Covering Index Guidelines

Create covering indexes when:
1. Query selects small number of additional columns
2. Query is high-frequency
3. Index size remains reasonable (< 5 included columns)

```sql
-- Example: Order summary query
CREATE INDEX IX_SalesOrders_Customer_Summary
ON sales.SalesOrders (CustomerId, OrderDate)
INCLUDE (OrderNumber, TotalAmount, Status)
WHERE IsDeleted = 0;
```

---

## Index Maintenance Considerations

- Limit indexes to those justified by query patterns
- Monitor index usage via DMVs
- Rebuild/reorganize based on fragmentation thresholds
- Consider filtered indexes for sparse data

---

# Transaction Strategy

## ACID Compliance

All transactions follow ACID properties:
- **Atomicity**: All or nothing
- **Consistency**: Database constraints maintained
- **Isolation**: Configurable per operation
- **Durability**: Committed data persisted

---

## Isolation Levels

| Operation Type | Isolation Level | Rationale |
|----------------|-----------------|-----------|
| Read operations | READ COMMITTED | Default, prevents dirty reads |
| Reports/analytics | READ UNCOMMITTED | Accept stale data for speed |
| Financial transactions | SERIALIZABLE | Prevent phantom reads |
| Inventory updates | REPEATABLE READ | Consistent read during update |

---

## Transaction Boundaries

**Application-Managed**: Transactions controlled at application layer using Unit of Work pattern.

```csharp
// Pseudo-code example
using var unitOfWork = unitOfWorkFactory.Create();
try
{
    // Multiple repository operations
    orderRepository.Add(order);
    foreach (var line in order.Lines)
    {
        inventoryRepository.Reserve(line.ProductId, line.Quantity);
    }
    paymentRepository.Add(payment);
    
    unitOfWork.Commit();
}
catch
{
    unitOfWork.Rollback();
    throw;
}
```

---

## Savepoint Strategy

For complex operations:
- Use savepoints for partial rollback
- Log savepoint names for debugging
- Document rollback conditions

---

# Concurrency Strategy

## Optimistic Concurrency

**Default approach**: RowVersion-based optimistic concurrency.

### Implementation

```sql
-- Every table includes:
RowVersion ROWVERSION NOT NULL
```

```csharp
// Update pattern
UPDATE sales.SalesOrders
SET Status = @NewStatus,
    ModifiedBy = @UserId,
    ModifiedDate = SYSUTCDATETIME(),
    RowVersion = RowVersion + 1  -- Implicit in ROWVERSION
WHERE Id = @Id 
  AND RowVersion = @OriginalRowVersion;

-- If no rows affected, concurrency conflict detected
```

### Conflict Resolution

1. **User notification**: Display conflict message
2. **Refresh data**: Show current state
3. **Retry option**: Allow user to re-submit
4. **Force override**: Admin-only bypass (logged)

---

## Pessimistic Concurrency

**Limited use cases**:
- Cash drawer operations
- Inventory allocation during checkout
- Sequential number generation

### Implementation

```sql
BEGIN TRANSACTION;

-- Lock the row
SELECT @CurrentNumber = CurrentValue
FROM reference.Sequences WITH (UPDLOCK, HOLDLOCK)
WHERE SequenceName = 'SalesOrderNumber';

-- Increment
UPDATE reference.Sequences
SET CurrentValue = CurrentValue + 1
WHERE SequenceName = 'SalesOrderNumber';

COMMIT TRANSACTION;
```

---

# Soft Delete Strategy

## Policy

**All business entities use soft delete.** Hard delete reserved for:
- Temporary/staging tables
- Audit log archival (after retention period)
- Explicit data purge requests (GDPR right to erasure)

---

## Implementation

```sql
-- Standard soft delete columns
IsDeleted        BIT          NOT NULL DEFAULT 0
DeletedBy        INT          NULL
DeletedDate      DATETIME2(0) NULL
```

---

## Query Patterns

All queries must filter out deleted records:

```sql
-- Standard WHERE clause
WHERE IsDeleted = 0

-- Or use views
CREATE VIEW core.vw_ActiveUsers AS
SELECT * FROM core.Users WHERE IsDeleted = 0;
```

---

## Referential Integrity with Soft Delete

**Challenge**: Foreign keys don't understand soft delete.

**Solutions**:

1. **Filtered unique constraints**:
```sql
CREATE UNIQUE INDEX UQ_Users_Company_Username
ON core.Users (CompanyId, Username)
WHERE IsDeleted = 0;
```

2. **Application-level enforcement**: Check `IsDeleted` before allowing references

3. **Cascading soft delete**: When parent soft-deleted, cascade to children

---

## Restore Capability

Soft-delete enables restore:
- Track deletion metadata (who, when, why)
- Provide undelete functionality for admins
- Retention policy for permanent cleanup

---

# Audit Strategy

## Dual-Layer Auditing

### Layer 1: Row-Level Audit Columns

Every table includes:
```sql
CreatedBy        INT          NOT NULL
CreatedDate      DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
ModifiedBy       INT          NULL
ModifiedDate     DATETIME2(0) NULL
DeletedBy        INT          NULL
DeletedDate      DATETIME2(0) NULL
```

---

### Layer 2: Change Log Table

For sensitive tables, maintain detailed change history:

```sql
CREATE TABLE audit.DataChangeLog (
    Id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    TableName       NVARCHAR(128) NOT NULL,
    RecordId        BIGINT NOT NULL,
    Operation       CHAR(1) NOT NULL,  -- I, U, D
    OldValues       NVARCHAR(MAX) NULL,  -- JSON
    NewValues       NVARCHAR(MAX) NULL,  -- JSON
    ChangedBy       INT NOT NULL,
    ChangedDate     DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    IpAddress       NVARCHAR(45) NULL,
    Application     NVARCHAR(128) NULL
);
```

---

## Tables Requiring Detailed Audit

| Table | Audit Level | Rationale |
|-------|-------------|-----------|
| Users | Full | Security-sensitive |
| Roles | Full | Authorization changes |
| Products | Full | Pricing, regulatory |
| InventoryItems | Full | Stock movements |
| SalesOrders | Full | Financial, legal |
| Payments | Full | Financial, compliance |
| PurchaseOrders | Full | Financial |

---

## Audit Data Retention

| Data Type | Retention Period | Storage Tier |
|-----------|------------------|--------------|
| Active transaction data | 7 years | Hot storage |
| Closed accounts | 7 years after closure | Warm storage |
| System logs | 1 year | Hot storage |
| Archived data | Per regulation | Cold storage |

---

# Backup Considerations

## Backup Strategy

| Backup Type | Frequency | Retention |
|-------------|-----------|-----------|
| Full | Daily (off-peak) | 30 days |
| Differential | Every 4 hours | 7 days |
| Transaction Log | Every 15 minutes | 7 days |

---

## Recovery Objectives

| Metric | Target | Rationale |
|--------|--------|-----------|
| RPO (Recovery Point Objective) | 15 minutes | Maximum acceptable data loss |
| RTO (Recovery Time Objective) | 4 hours | Maximum acceptable downtime |

---

## Backup Verification

- Monthly restore testing to isolated environment
- Verify backup integrity with CHECKSUM
- Document restore procedures

---

# Performance Considerations

## Query Optimization

1. **Parameter sniffing**: Use `OPTION (RECOMPILE)` for variable plans
2. **Statistics**: Auto-update enabled, monitor skew
3. **Query Store**: Enabled for plan regression detection

---

## Partitioning Strategy

**Future-ready design** for large tables:

| Table | Partition Key | Threshold |
|-------|---------------|-----------|
| StockLedger | TransactionDate (monthly) | > 10M rows |
| SalesOrders | OrderDate (yearly) | > 50M rows |
| DataChangeLog | ChangedDate (monthly) | > 100M rows |

---

## Archival Strategy

- Move historical data to archive tables
- Maintain current year in main tables
- Archive process runs monthly

---

# Scalability Considerations

## Vertical Scaling

- Start with appropriate server size
- Monitor and scale CPU/RAM as needed
- SQL Server supports up to 64TB memory

---

## Horizontal Scaling Options

| Technique | Use Case | Complexity |
|-----------|----------|------------|
| Read Replicas | Reporting offload | Low |
| Sharding by Company | Multi-tenant | Medium |
| Sharding by Branch | Geographic distribution | High |
| Azure SQL Hyperscale | Cloud elasticity | Low (cloud only) |

---

## Connection Pooling

- Application-level connection pooling enabled
- Recommended pool size: 100 connections per app instance
- Monitor for connection leaks

---

# Security Considerations

## Database Authentication

- Windows Authentication preferred for internal services
- SQL Authentication for external integrations (with strong passwords)
- Service accounts with minimal privileges

---

## Authorization

- Database roles map to application roles
- Schema-level permissions
- Row-level security for multi-tenant scenarios (future)

---

## Encryption

| Data State | Method |
|------------|--------|
| At Rest | TDE (Transparent Data Encryption) |
| In Transit | TLS 1.2+ |
| Sensitive Columns | Always Encrypted (for PII) |

---

## Auditing

- SQL Server Audit enabled for DDL changes
- Login auditing enabled
- Failed access attempts logged

---

# Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0003 | Architecture Team | Initial release |

---

# References

- [Canonical Data Model](13-canonical-data-model.md)
- [Database Standards](12-database-standards.md)
- [Entity Relationship Model](15-entity-relationship-model.md)
- ADR-0003: Why SQL Server
- ADR-0004: Why ADO.NET instead of Entity Framework
- ADR-0005: Why Repository Pattern + Unit of Work
