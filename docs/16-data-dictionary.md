# Data Dictionary

## PharmaX Enterprise Platform

**Version:** 1.0  
**Document ID:** DD-001  
**Created:** WO-0003  
**Status:** Approved  

---

## Overview

This data dictionary provides detailed definitions for every table in the PharmaX Enterprise database, including column purposes, data types, constraints, and relationships.

---

# Core Schema Tables

## core.Companies

**Purpose**: Stores legal business entities that own and operate branches.

| Column | Type | Nullable | Constraints | Description |
|--------|------|----------|-------------|-------------|
| Id | BIGINT | NO | PK, IDENTITY | Unique identifier |
| Code | NVARCHAR(50) | NO | UNIQUE | Unique company code |
| Name | NVARCHAR(200) | NO | - | Legal business name |
| TradeName | NVARCHAR(200) | YES | - | DBA / trading name |
| TaxIdentificationNumber | NVARCHAR(50) | YES | - | Tax ID / VAT number |
| RegistrationNumber | NVARCHAR(50) | YES | - | Business registration number |
| Status | NVARCHAR(20) | NO | CK: Active/Inactive/Suspended | Company status |
| IsHeadOffice | BIT | NO | DF: 0 | Head office flag |
| CreatedBy | INT | NO | - | Creating user ID |
| CreatedDate | DATETIME2(0) | NO | DF: SYSUTCDATETIME() | Creation timestamp (UTC) |
| ModifiedBy | INT | YES | - | Last modifying user ID |
| ModifiedDate | DATETIME2(0) | YES | - | Last modification timestamp |
| IsDeleted | BIT | NO | DF: 0 | Soft delete flag |
| DeletedBy | INT | YES | - | Deleting user ID |
| DeletedDate | DATETIME2(0) | YES | - | Deletion timestamp |
| RowVersion | ROWVERSION | NO | - | Optimistic concurrency token |

**Relationships**:
- Parent: None (root entity)
- Children: Branches, Users, Roles

---

## core.Branches

**Purpose**: Stores physical locations where business operations occur.

| Column | Type | Nullable | Constraints | Description |
|--------|------|----------|-------------|-------------|
| Id | BIGINT | NO | PK, IDENTITY | Unique identifier |
| CompanyId | BIGINT | NO | FK → Companies.Id | Parent company |
| Code | NVARCHAR(50) | NO | UQ (CompanyId, Code) | Branch code (unique per company) |
| Name | NVARCHAR(200) | NO | - | Branch name |
| Type | NVARCHAR(20) | NO | CK: Retail/Warehouse/Office/Distribution | Branch type |
| AddressLine1 | NVARCHAR(200) | YES | - | Street address |
| AddressLine2 | NVARCHAR(200) | YES | - | Additional address |
| City | NVARCHAR(100) | YES | - | City |
| StateProvince | NVARCHAR(100) | YES | - | State/province |
| Country | NVARCHAR(100) | YES | - | Country |
| PostalCode | NVARCHAR(20) | YES | - | ZIP/postal code |
| PhoneNumber | NVARCHAR(50) | YES | - | Contact phone |
| Email | NVARCHAR(100) | YES | - | Contact email |
| OperatingHours | NVARCHAR(200) | YES | - | Business hours description |
| Status | NVARCHAR(20) | NO | CK: Active/Inactive/Maintenance/Closed | Branch status |
| IsHeadOffice | BIT | NO | DF: 0 | Head office flag |
| ParentBranchId | BIGINT | YES | FK → Branches.Id | Parent branch for hierarchy |
| CreatedBy | INT | NO | - | Creating user ID |
| CreatedDate | DATETIME2(0) | NO | DF: SYSUTCDATETIME() | Creation timestamp |
| ModifiedBy | INT | YES | - | Last modifying user ID |
| ModifiedDate | DATETIME2(0) | YES | - | Last modification timestamp |
| IsDeleted | BIT | NO | DF: 0 | Soft delete flag |
| DeletedBy | INT | YES | - | Deleting user ID |
| DeletedDate | DATETIME2(0) | YES | - | Deletion timestamp |
| RowVersion | ROWVERSION | NO | - | Concurrency token |

**Relationships**:
- Parent: Companies
- Children: Warehouses, Counters, Users (assignment), SalesOrders, PurchaseOrders

---

## core.Users

**Purpose**: Stores system users with authentication credentials.

| Column | Type | Nullable | Constraints | Description |
|--------|------|----------|-------------|-------------|
| Id | BIGINT | NO | PK, IDENTITY | Unique identifier |
| CompanyId | BIGINT | NO | FK → Companies.Id | Employing company |
| Username | NVARCHAR(100) | NO | UQ (CompanyId, Username) | Login username |
| Email | NVARCHAR(256) | NO | UNIQUE | Email address (globally unique) |
| PasswordHash | NVARCHAR(512) | NO | - | Hashed password |
| FirstName | NVARCHAR(100) | NO | - | First name |
| LastName | NVARCHAR(100) | NO | - | Last name |
| PhoneNumber | NVARCHAR(50) | YES | - | Contact phone |
| EmployeeId | NVARCHAR(50) | YES | - | Employee number |
| Department | NVARCHAR(100) | YES | - | Department name |
| JobTitle | NVARCHAR(100) | YES | - | Job title |
| Status | NVARCHAR(20) | NO | CK: Active/Suspended/Terminated/Locked | Account status |
| LastLoginDate | DATETIME2(0) | YES | - | Last successful login |
| PasswordChangedDate | DATETIME2(0) | YES | - | Last password change |
| FailedLoginAttempts | INT | NO | DF: 0 | Current failed attempt count |
| LockoutEndDate | DATETIME2(0) | YES | - | Account lockout expiry |
| DefaultBranchId | BIGINT | YES | FK → Branches.Id | Default work branch |
| CreatedBy | INT | NO | - | Creating user ID |
| CreatedDate | DATETIME2(0) | NO | DF: SYSUTCDATETIME() | Creation timestamp |
| ModifiedBy | INT | YES | - | Last modifying user ID |
| ModifiedDate | DATETIME2(0) | YES | - | Last modification timestamp |
| IsDeleted | BIT | NO | DF: 0 | Soft delete flag |
| DeletedBy | INT | YES | - | Deleting user ID |
| DeletedDate | DATETIME2(0) | YES | - | Deletion timestamp |
| RowVersion | ROWVERSION | NO | - | Concurrency token |

**Relationships**:
- Parent: Companies, Branches (default)
- Children: Sessions, UserRoles

---

## core.Roles

**Purpose**: Stores role definitions for RBAC authorization.

| Column | Type | Nullable | Constraints | Description |
|--------|------|----------|-------------|-------------|
| Id | BIGINT | NO | PK, IDENTITY | Unique identifier |
| CompanyId | BIGINT | YES | FK → Companies.Id | Owning company (NULL = system role) |
| Name | NVARCHAR(100) | NO | UQ (CompanyId, Name) | Role name |
| Description | NVARCHAR(500) | YES | - | Role description |
| BranchId | BIGINT | YES | FK → Branches.Id | Branch scope (NULL = company-wide) |
| IsSystemRole | BIT | NO | DF: 0 | System role flag |
| IsLocked | BIT | NO | DF: 0 | Locked from modification |
| Status | NVARCHAR(20) | NO | CK: Active/Inactive | Role status |
| CreatedBy | INT | NO | - | Creating user ID |
| CreatedDate | DATETIME2(0) | NO | DF: SYSUTCDATETIME() | Creation timestamp |
| ModifiedBy | INT | YES | - | Last modifying user ID |
| ModifiedDate | DATETIME2(0) | YES | - | Last modification timestamp |
| IsDeleted | BIT | NO | DF: 0 | Soft delete flag |
| DeletedBy | INT | YES | - | Deleting user ID |
| DeletedDate | DATETIME2(0) | YES | - | Deletion timestamp |
| RowVersion | ROWVERSION | NO | - | Concurrency token |

**Relationships**:
- Parent: Companies, Branches
- Children: UserRoles, RolePermissions

---

## core.Permissions

**Purpose**: Stores granular permission definitions.

| Column | Type | Nullable | Constraints | Description |
|--------|------|----------|-------------|-------------|
| Id | BIGINT | NO | PK, IDENTITY | Unique identifier |
| Code | NVARCHAR(100) | NO | UNIQUE | Permission code (e.g., SALES.CREATE) |
| Name | NVARCHAR(200) | NO | - | Display name |
| Description | NVARCHAR(500) | YES | - | Permission description |
| Category | NVARCHAR(100) | NO | - | Permission category |
| IsSystem | BIT | NO | DF: 1, CK: = 1 | System permission flag |
| CreatedBy | INT | NO | - | Creating user ID |
| CreatedDate | DATETIME2(0) | NO | DF: SYSUTCDATETIME() | Creation timestamp |
| ModifiedBy | INT | YES | - | Last modifying user ID |
| ModifiedDate | DATETIME2(0) | YES | - | Last modification timestamp |
| IsDeleted | BIT | NO | DF: 0 | Soft delete flag |
| DeletedBy | INT | YES | - | Deleting user ID |
| DeletedDate | DATETIME2(0) | YES | - | Deletion timestamp |
| RowVersion | ROWVERSION | NO | - | Concurrency token |

**Relationships**:
- Parent: None (system-defined)
- Children: RolePermissions

---

# Product Schema Tables

## product.Products

**Purpose**: Stores pharmaceutical product catalog entries.

| Column | Type | Nullable | Constraints | Description |
|--------|------|----------|-------------|-------------|
| Id | BIGINT | NO | PK, IDENTITY | Unique identifier |
| CompanyId | BIGINT | NO | FK → Companies.Id | Owning company |
| SKU | NVARCHAR(100) | NO | UQ (CompanyId, SKU) | Stock keeping unit |
| Name | NVARCHAR(300) | NO | - | Product name |
| GenericName | NVARCHAR(200) | YES | - | Generic/INN name |
| BrandName | NVARCHAR(200) | YES | - | Brand/trade name |
| Description | NVARCHAR(1000) | YES | - | Product description |
| ManufacturerId | BIGINT | YES | FK → Manufacturers.Id | Manufacturer |
| CategoryId | BIGINT | NO | FK → Categories.Id | Product category |
| GenericId | BIGINT | YES | FK → Generics.Id | Generic classification |
| BrandId | BIGINT | YES | FK → Brands.Id | Brand classification |
| TherapeuticClass | NVARCHAR(200) | YES | - | Therapeutic class |
| ATCCode | NVARCHAR(50) | YES | - | WHO ATC code |
| DosageForm | NVARCHAR(100) | YES | - | Tablet, capsule, etc. |
| Strength | NVARCHAR(100) | YES | - | e.g., 500mg |
| UnitOfMeasureId | BIGINT | YES | FK → Units.Id | Base unit |
| StorageConditions | NVARCHAR(500) | YES | - | Storage requirements |
| RequiresRefrigeration | BIT | NO | DF: 0 | Cold chain required |
| IsControlledSubstance | BIT | NO | DF: 0 | Controlled substance flag |
| ControlledSubstanceSchedule | NVARCHAR(20) | YES | - | Schedule (e.g., C-II) |
| PrescriptionRequired | BIT | NO | DF: 0 | Rx required flag |
| Status | NVARCHAR(20) | NO | CK: Active/Discontinued/Recalled/Pending | Product status |
| TaxCategoryId | BIGINT | YES | FK → finance.TaxRates.Id | Tax category |
| ReorderLevel | INT | NO | DF: 0 | Minimum stock level |
| MaxStockLevel | INT | NO | DF: 0 | Maximum stock level |
| CreatedBy | INT | NO | - | Creating user ID |
| CreatedDate | DATETIME2(0) | NO | DF: SYSUTCDATETIME() | Creation timestamp |
| ModifiedBy | INT | YES | - | Last modifying user ID |
| ModifiedDate | DATETIME2(0) | YES | - | Last modification timestamp |
| IsDeleted | BIT | NO | DF: 0 | Soft delete flag |
| DeletedBy | INT | YES | - | Deleting user ID |
| DeletedDate | DATETIME2(0) | YES | - | Deletion timestamp |
| RowVersion | ROWVERSION | NO | - | Concurrency token |

**Relationships**:
- Parents: Companies, Categories, Manufacturers, Generics, Brands, Units
- Children: ProductVariants, ProductBarcodes, InventoryItems, SalesOrderLines, PurchaseOrderLines

---

## product.ProductVariants

**Purpose**: Stores product packaging/presentation variations.

| Column | Type | Nullable | Constraints | Description |
|--------|------|----------|-------------|-------------|
| Id | BIGINT | NO | PK, IDENTITY | Unique identifier |
| ProductId | BIGINT | NO | FK → Products.Id | Parent product |
| VariantType | NVARCHAR(50) | NO | - | Type (PackSize, Presentation) |
| VariantValue | NVARCHAR(100) | NO | - | Value (e.g., "10 tablets") |
| SKU | NVARCHAR(100) | YES | UNIQUE | Variant-specific SKU |
| Barcode | NVARCHAR(100) | YES | UNIQUE | Variant barcode |
| Price | DECIMAL(18,4) | NO | DF: 0, CK: >= 0 | Selling price |
| CostPrice | DECIMAL(18,4) | NO | DF: 0, CK: >= 0 | Cost price |
| ReorderLevel | INT | NO | DF: 0 | Reorder threshold |
| MaxStockLevel | INT | NO | DF: 0 | Max stock level |
| Status | NVARCHAR(20) | NO | CK: Active/Inactive | Variant status |
| CreatedBy | INT | NO | - | Creating user ID |
| CreatedDate | DATETIME2(0) | NO | DF: SYSUTCDATETIME() | Creation timestamp |
| ModifiedBy | INT | YES | - | Last modifying user ID |
| ModifiedDate | DATETIME2(0) | YES | - | Last modification timestamp |
| IsDeleted | BIT | NO | DF: 0 | Soft delete flag |
| DeletedBy | INT | YES | - | Deleting user ID |
| DeletedDate | DATETIME2(0) | YES | - | Deletion timestamp |
| RowVersion | ROWVERSION | NO | - | Concurrency token |

**Relationships**:
- Parent: Products
- Children: InventoryItems, SalesOrderLines, PurchaseOrderLines

---

# Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0003 | Architecture Team | Initial release (partial - core and product schemas) |

---

# Notes

This data dictionary is a **living document**. The following schemas are defined in separate SQL schema files:

- **core**: Organization and security tables (complete)
- **product**: Product catalog tables (complete)
- **inventory**: Stock management tables (defined in 003-inventory-schema.sql)
- **purchasing**: Procurement tables (defined in 004-purchasing-schema.sql)
- **sales**: Sales transaction tables (defined in 005-sales-schema.sql)
- **finance**: Financial tables (defined in 006-finance-schema.sql)
- **reference**: Lookup tables (defined in 099-reference-schema.sql)
- **audit**: Audit log tables (defined in 099-audit-schema.sql)

---

# References

- [Canonical Data Model](13-canonical-data-model.md)
- [Database Architecture](14-database-architecture.md)
- [Entity Relationship Model](15-entity-relationship-model.md)
