# Domain Model

## PharmaX Enterprise Platform

**Version:** 1.0  
**Document ID:** DOM-001  
**Created:** WO-0001  

---

## Overview

This document describes the conceptual domain model for PharmaX Enterprise. It identifies primary business entities, their relationships, ownership, and high-level business rules. This is a **conceptual model only** — database schema design will be addressed in subsequent work orders.

---

## Entity Relationship Diagram (Conceptual)

```
┌─────────────────┐         ┌─────────────────┐
│     Company     │────────<│      Branch     │
└────────┬────────┘         └────────┬────────┘
         │                           │
         │                           │
    ┌────▼───────────────────────────▼────┐
    │              User                   │
    └─────────────────┬───────────────────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
    ┌────▼────┐  ┌────▼────┐  ┌───▼────┐
    │  Role   │  │Permission│  │ Session│
    └────┬────┘  └──────────┘  └────────┘
         │
         │<──────────────────────────────┐
         │                               │
    ┌────▼───────────────────────────────▼────┐
    │           UserRole (Association)        │
    └─────────────────────────────────────────┘

┌─────────────────┐         ┌─────────────────┐
│     Product     │────────<│   ProductVariant│
└────────┬────────┘         └─────────────────┘
         │
         │
    ┌────▼────────┐
    │  Category   │
    └─────────────┘

┌─────────────────┐         ┌─────────────────┐
│     Branch      │────────<│  InventoryItem  │
└─────────────────┘         └────────┬────────┘
                                     │
                                ┌────▼────┐
                                │ Product │
                                └─────────┘

┌─────────────────┐         ┌─────────────────┐
│    Supplier     │────────<│ PurchaseOrder   │
└─────────────────┘         └────────┬────────┘
                                     │
                                ┌────▼────┐
                                │  Branch │
                                └─────────┘

┌─────────────────┐         ┌─────────────────┐
│    Customer     │────────<│    SalesOrder   │
└─────────────────┘         └────────┬────────┘
                                     │
                                ┌────▼────┐
                                │  Branch │
                                └─────────┘
```

---

## Core Entities

### 1. Company

**Purpose**: Represents a legal business entity within the enterprise.

**Attributes**:
- Id (unique identifier)
- Code (unique company code)
- Name (legal name)
- TradeName (doing-business-as name)
- TaxIdentificationNumber
- RegistrationNumber
- Status (Active, Inactive, Suspended)
- CreatedDate
- ModifiedDate

**Relationships**:
- Has many Branches
- Has many Users (employment relationship)
- Has many Roles (defined at company level)

**Ownership**: Enterprise-level entity, managed by System Administrators.

**Business Rules**:
- Company code must be unique across the system.
- A company cannot be deleted if it has active branches.
- At least one company must exist in the system.
- Company status changes require administrative approval.

---

### 2. Branch

**Purpose**: Represents a physical location or operational unit of a company.

**Attributes**:
- Id
- CompanyId (foreign key)
- Code (unique within company)
- Name
- Type (Retail, Warehouse, Office, Distribution)
- Address
- City
- State/Province
- Country
- PostalCode
- PhoneNumber
- Email
- OperatingHours
- Status (Active, Inactive, Maintenance)
- IsHeadOffice (flag)
- ParentBranchId (for hierarchy)

**Relationships**:
- Belongs to one Company
- Has many Users (assigned users)
- Has many InventoryItems
- Has many SalesOrders
- Has many PurchaseOrders
- May have parent/child Branch relationships

**Ownership**: Company-level entity, managed by Company Administrators.

**Business Rules**:
- Branch code must be unique within its company.
- A branch must belong to exactly one company.
- Deleting a company cascades to its branches.
- A branch cannot be deleted if it has inventory.
- Head office flag can only be set for one branch per company.

---

### 3. User

**Purpose**: Represents a system user with access credentials.

**Attributes**:
- Id
- Username
- Email
- PasswordHash
- FirstName
- LastName
- PhoneNumber
- EmployeeId
- Department
- JobTitle
- Status (Active, Suspended, Terminated, Locked)
- LastLoginDate
- PasswordChangedDate
- FailedLoginAttempts
- LockoutEndDate
- CreatedByCompanyId
- DefaultBranchId

**Relationships**:
- Belongs to one Company (employer)
- May have a default Branch assignment
- Has many Roles (through UserRole association)
- Has many Sessions
- Created by another User

**Ownership**: Company-level entity, managed by Company/Branch Administrators.

**Business Rules**:
- Username must be unique within the company.
- Email must be unique across the system.
- Password must meet complexity requirements.
- Account locks after N failed login attempts.
- Users cannot be deleted; they are soft-deleted (status change).
- A user must have at least one role.

---

### 4. Role

**Purpose**: Defines a collection of permissions that can be assigned to users.

**Attributes**:
- Id
- Name
- Description
- CompanyId (nullable for system roles)
- BranchId (nullable for branch-specific roles)
- IsSystemRole (flag for built-in roles)
- IsLocked (prevents modification)
- Status (Active, Inactive)
- CreatedDate

**Relationships**:
- Belongs to zero or one Company (system roles have no company)
- May be scoped to a Branch
- Has many Permissions (through RolePermission association)
- Assigned to many Users (through UserRole association)

**Ownership**: Company-level or System-level, depending on role type.

**Business Rules**:
- Role name must be unique within its scope (company or system).
- System roles cannot be deleted.
- Roles cannot be deleted if assigned to users.
- A role must have at least one permission.
- Role modifications are audited.

---

### 5. Permission

**Purpose**: Represents a granular authorization right within the system.

**Attributes**:
- Id
- Code (e.g., "SALES.CREATE", "INVENTORY.VIEW")
- Name
- Description
- Category (Authentication, Sales, Inventory, etc.)
- IsSystem (flag for built-in permissions)
- CreatedDate

**Relationships**:
- Assigned to many Roles (through RolePermission association)
- Part of one Category

**Ownership**: System-level entity, managed by System Administrators.

**Business Rules**:
- Permission code must be unique and follow naming convention.
- System permissions cannot be deleted.
- New permissions require code deployment.
- Permission categories help organize UI presentation.

---

### 6. UserRole (Association Entity)

**Purpose**: Links users to roles with optional scoping.

**Attributes**:
- Id
- UserId
- RoleId
- CompanyId (scope)
- BranchId (optional scope)
- GrantedBy (user who assigned)
- GrantedDate
- ExpiryDate (optional)
- IsActive

**Relationships**:
- Links one User to one Role
- Scoped to Company and optionally Branch

**Ownership**: Company-level, managed by Administrators.

**Business Rules**:
- A user can have multiple roles.
- The same role can be assigned multiple times with different scopes.
- Expired role assignments are automatically inactive.
- Role assignment changes are audited.

---

### 7. RolePermission (Association Entity)

**Purpose**: Links roles to permissions.

**Attributes**:
- Id
- RoleId
- PermissionId
- GrantedBy
- GrantedDate

**Relationships**:
- Links one Role to one Permission

**Ownership**: Company/System-level, depending on role ownership.

**Business Rules**:
- A role can have multiple permissions.
- Duplicate permission assignments are not allowed.
- Permission changes to roles affect all users with that role.

---

### 8. Session

**Purpose**: Tracks active user sessions for security and auditing.

**Attributes**:
- Id
- UserId
- Token/SessionId
- BranchId (session context)
- CompanyId (session context)
- IPAddress
- UserAgent
- LoginTime
- LastActivityTime
- ExpiryTime
- LogoutTime
- Status (Active, Expired, Terminated)
- TerminationReason

**Relationships**:
- Belongs to one User
- Associated with one Branch (context)
- Associated with one Company (context)

**Ownership**: System-level, managed by Authentication service.

**Business Rules**:
- Users may have multiple concurrent sessions (configurable).
- Sessions expire after period of inactivity.
- Forced logout terminates all active sessions.
- Session data is retained for audit purposes.

---

### 9. Product

**Purpose**: Represents a pharmaceutical product in the catalog.

**Attributes**:
- Id
- SKU (Stock Keeping Unit)
- Name
- GenericName
- BrandName
- Description
- ManufacturerId
- CategoryId
- TherapeuticClass
- ATCCode
- DosageForm (Tablet, Capsule, Liquid, etc.)
- Strength
- UnitOfMeasure
- StorageConditions
- RequiresRefrigeration (flag)
- IsControlledSubstance (flag)
- ControlledSubstanceSchedule
- PrescriptionRequired (flag)
- Status (Active, Discontinued, Recalled)
- Barcode
- TaxCategory

**Relationships**:
- Belongs to one Category
- Has many ProductVariants
- Manufactured by one Manufacturer
- Appears in many InventoryItems
- Appears in many SalesOrderLines
- Appears in many PurchaseOrderLines

**Ownership**: Company-level or Enterprise-level (shared catalog).

**Business Rules**:
- SKU must be unique within the company.
- Barcode must be unique across the system.
- Products cannot be deleted if they have inventory or transactions.
- Discontinuing a product requires zero inventory.
- Controlled substances require additional tracking.

---

### 10. ProductVariant

**Purpose**: Represents a specific variation of a product (packaging, size).

**Attributes**:
- Id
- ProductId
- VariantType (PackSize, Presentation)
- VariantValue (e.g., "10 tablets", "100ml bottle")
- SKU (if different from parent)
- Barcode (if different)
- Price
- CostPrice
- ReorderLevel
- MaxStockLevel
- Status (Active, Inactive)

**Relationships**:
- Belongs to one Product
- Appears in InventoryItems

**Ownership**: Company-level.

**Business Rules**:
- Variant SKU must be unique.
- Price must be non-negative.
- Reorder level must be less than max stock level.

---

### 11. Category

**Purpose**: Hierarchical classification of products.

**Attributes**:
- Id
- Name
- Code
- Description
- ParentCategoryId
- Level
- SortOrder
- IsActive

**Relationships**:
- May have a parent Category (self-referential)
- Has many child Categories
- Has many Products

**Ownership**: Company-level or Enterprise-level.

**Business Rules**:
- Category code must be unique.
- Circular references in hierarchy are not allowed.
- Categories cannot be deleted if they contain products.
- Maximum hierarchy depth may be enforced.

---

### 12. InventoryItem

**Purpose**: Tracks product stock at a specific location.

**Attributes**:
- Id
- BranchId
- ProductId
- ProductVariantId
- BatchNumber
- SerialNumber (optional)
- QuantityOnHand
- QuantityReserved
- QuantityAvailable (calculated)
- UnitCost
- ExpiryDate
- ManufacturingDate
- ReceivedDate
- Location (bin/shelf)
- Status (Available, Reserved, Damaged, Expired, Quarantine)

**Relationships**:
- Belongs to one Branch
- References one Product
- References one ProductVariant (optional)
- Part of InventoryMovements

**Ownership**: Branch-level.

**Business Rules**:
- Quantity cannot be negative.
- Available = OnHand - Reserved.
- Expired items cannot be sold.
- Batch number is required for pharmaceutical products.
- Expiry date tracking is mandatory.
- Stock adjustments require authorization.

---

### 13. Supplier

**Purpose**: Represents a vendor/supplier of products.

**Attributes**:
- Id
- Code
- Name
- ContactPerson
- Email
- PhoneNumber
- Address
- City
- Country
- TaxIdentificationNumber
- PaymentTerms
- Currency
- Rating
- Status (Active, Inactive, Blocked)
- IsPreferred (flag)

**Relationships**:
- Supplies many Products (through ProductSupplier)
- Has many PurchaseOrders

**Ownership**: Company-level.

**Business Rules**:
- Supplier code must be unique.
- Suppliers cannot be deleted if they have outstanding orders.
- Blocked suppliers cannot receive new purchase orders.

---

### 14. PurchaseOrder

**Purpose**: Represents an order placed with a supplier.

**Attributes**:
- Id
- OrderNumber
- BranchId
- SupplierId
- OrderDate
- ExpectedDeliveryDate
- ActualDeliveryDate
- Status (Draft, Submitted, Approved, PartiallyReceived, Completed, Cancelled)
- TotalAmount
- DiscountAmount
- TaxAmount
- GrandTotal
- Notes
- OrderedBy (UserId)
- ApprovedBy (UserId)
- ApprovedDate

**Relationships**:
- Belongs to one Branch
- Placed with one Supplier
- Has many PurchaseOrderLines
- Created by one User
- Approved by one User

**Ownership**: Branch-level or Company-level.

**Business Rules**:
- Order number must be unique and follow sequence.
- Purchase orders over threshold require approval.
- Cannot receive more than ordered quantity without amendment.
- Cancelled orders cannot be modified.
- Completed orders trigger inventory receipt.

---

### 15. PurchaseOrderLine

**Purpose**: Line item within a purchase order.

**Attributes**:
- Id
- PurchaseOrderId
- ProductId
- ProductVariantId
- QuantityOrdered
- QuantityReceived
- UnitPrice
- DiscountPercent
- TaxPercent
- LineTotal
- ExpectedDeliveryDate

**Relationships**:
- Belongs to one PurchaseOrder
- References one Product

**Ownership**: Part of PurchaseOrder.

**Business Rules**:
- Quantity received cannot exceed quantity ordered.
- Unit price must be positive.
- Line total is calculated.

---

### 16. Customer

**Purpose**: Represents a customer for sales transactions.

**Attributes**:
- Id
- Code
- FirstName
- LastName
- Email
- PhoneNumber
- Address
- City
- Country
- DateOfBirth (optional)
- Gender (optional)
- CustomerType (Individual, Organization)
- OrganizationName (if organization)
- TaxExempt (flag)
- TaxExemptionNumber
- LoyaltyPoints
- CreditLimit
- Status (Active, Inactive, Blocked)
- CreatedDate

**Relationships**:
- Has many SalesOrders
- Has many Payments
- Assigned to one Branch (home branch, optional)

**Ownership**: Branch-level or Company-level.

**Business Rules**:
- Customer code must be unique.
- Email must be unique if provided.
- Blocked customers cannot make purchases.
- Credit limit enforcement is configurable.

---

### 17. SalesOrder

**Purpose**: Represents a sales transaction (POS or order).

**Attributes**:
- Id
- OrderNumber
- InvoiceNumber
- BranchId
- CustomerId (optional for walk-in)
- OrderDate
- OrderType (POS, Order, Quote)
- Status (Draft, Completed, Voided, Refunded)
- Subtotal
- DiscountAmount
- TaxAmount
- TotalAmount
- AmountPaid
- BalanceDue
- PaymentStatus (Unpaid, PartiallyPaid, Paid)
- CashierId (UserId)
- Notes
- PrescriptionReference (optional)

**Relationships**:
- Belongs to one Branch
- Associated with one Customer (optional)
- Has many SalesOrderLines
- Has many Payments
- Processed by one User (cashier)

**Ownership**: Branch-level.

**Business Rules**:
- Order number must be unique and sequential.
- Invoice generated on completion.
- Voided orders cannot be modified.
- Refunds require authorization.
- Prescription products require valid prescription.
- Negative sales are processed as returns.

---

### 18. SalesOrderLine

**Purpose**: Line item within a sales order.

**Attributes**:
- Id
- SalesOrderId
- ProductId
- ProductVariantId
- BatchNumber (from inventory)
- Quantity
- UnitPrice
- DiscountPercent
- TaxPercent
- LineTotal
- CostPrice (snapshot)
- ProfitMargin (calculated)

**Relationships**:
- Belongs to one SalesOrder
- References one Product
- Consumes InventoryItem

**Ownership**: Part of SalesOrder.

**Business Rules**:
- Quantity cannot exceed available inventory.
- Unit price must be positive.
- Batch number is assigned from inventory.
- Profit margin is calculated at time of sale.

---

### 19. Payment

**Purpose**: Records payment against sales orders or from customers.

**Attributes**:
- Id
- PaymentNumber
- SalesOrderId (optional)
- CustomerId (optional)
- BranchId
- PaymentDate
- PaymentMethod (Cash, Card, Check, Transfer)
- Amount
- ReferenceNumber (check #, transaction ID)
- CardLastFour (if card)
- Status (Pending, Completed, Failed, Reversed)
- ProcessedBy (UserId)
- Notes

**Relationships**:
- Associated with one SalesOrder (optional)
- Made by one Customer (optional)
- Processed at one Branch
- Processed by one User

**Ownership**: Branch-level.

**Business Rules**:
- Payment number must be unique.
- Payment amount must be positive.
- Overpayments create customer credit.
- Reversed payments require authorization.
- Daily reconciliation is required.

---

## Aggregate Roots

The following entities serve as aggregate roots for transactional consistency:

| Aggregate Root | Contains |
|---------------|----------|
| Company | Branches, Company-level settings |
| Branch | Inventory, Branch-level operations |
| User | Sessions, Role assignments |
| Role | Permissions (via association) |
| Product | Variants |
| PurchaseOrder | Lines |
| SalesOrder | Lines, Payments |
| Customer | (standalone) |
| Supplier | (standalone) |

---

## Value Objects

The following concepts should be modeled as value objects:

| Value Object | Used By | Attributes |
|-------------|---------|------------|
| Money | Product, Order, Payment | Amount, Currency |
| Address | Company, Branch, Customer, Supplier | Street, City, State, PostalCode, Country |
| OperatingHours | Branch | DayOfWeek, OpenTime, CloseTime, IsClosed |
| ContactInfo | User, Customer, Supplier | Email, Phone, Mobile |
| DateRange | Reports, Filters | StartDate, EndDate |
| AuditInfo | All entities | CreatedBy, CreatedDate, ModifiedBy, ModifiedDate |

---

## Domain Events

The following domain events should be raised:

| Event | Trigger | Handlers |
|-------|---------|----------|
| UserLoggedIn | Successful authentication | Audit logging, Session creation |
| UserLoggedOut | Logout action | Session termination, Audit logging |
| PasswordChanged | Password update | Notification, Audit logging |
| AccountLocked | Failed login threshold | Notification, Security alert |
| RoleAssigned | UserRole creation | Cache invalidation, Notification |
| ProductCreated | New product | Catalog cache update |
| StockLevelChanged | Inventory movement | Reorder check, Notification |
| StockExpired | Expiry date reached | Alert, Quarantine action |
| PurchaseOrderSubmitted | Order submission | Approval workflow, Notification |
| PurchaseOrderApproved | Approval action | Order processing, Notification |
| GoodsReceived | Purchase order receipt | Inventory update, Accounting |
| SalesOrderCompleted | Transaction completion | Inventory deduction, Receipt generation |
| PaymentReceived | Payment processing | Accounting, Receipt generation |
| LowStockDetected | Inventory check | Reorder suggestion, Notification |

---

## Business Rule Categories

### Security Rules
- Authentication required for all operations
- Authorization based on roles and permissions
- Session management and timeout
- Password policies enforced
- Audit trail for sensitive operations

### Inventory Rules
- FIFO (First-In-First-Out) for expiry management
- No negative stock allowed
- Expired items quarantined automatically
- Batch tracking mandatory
- Stock adjustments require approval

### Sales Rules
- Prescription verification for controlled substances
- Price overrides require authorization
- Returns within configured timeframe only
- Discounts within user permission limits
- Cashier accountability per shift

### Purchasing Rules
- Approval thresholds enforced
- Supplier validation required
- Three-way match (PO, Receipt, Invoice)
- Preferred supplier priority
- Lead time considerations

### Financial Rules
- Sequential invoice numbering
- No back-dated transactions without approval
- Daily cash reconciliation
- Tax calculation per jurisdiction
- Audit trail for all financial transactions

---

## Domain Constraints

1. **Temporal Consistency**: Dates cannot be in the future unless explicitly allowed (e.g., expected delivery).
2. **Monetary Precision**: All currency values use decimal with appropriate precision.
3. **Quantity Integrity**: Quantities are non-negative decimals.
4. **Referential Integrity**: All foreign keys must reference existing records.
5. **Soft Delete**: Critical entities use soft delete (status flag) instead of hard delete.
6. **Audit Trail**: All modifications tracked with who, when, what.

---

## Related Documents

- [Architecture Overview](./01-architecture-overview.md)
- [Module Map](./02-module-map.md)
- [Repository Standards](./04-repository-standards.md)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0001 | Architecture Team | Initial domain model definition |

---

*This document is part of the PharmaX Enterprise architectural documentation suite.*
