# Canonical Data Model (CDM)

## PharmaX Enterprise Platform

**Version:** 1.0  
**Document ID:** CDM-001  
**Created:** WO-0003  
**Status:** Approved  

---

## Overview

The Canonical Data Model (CDM) defines the single source of truth for business terminology within the PharmaX Enterprise platform. This document establishes the standard business concepts, their definitions, relationships, and rules that will guide all implementation efforts.

The CDM is designed to support:
- Single pharmacy operations
- Multi-branch enterprise deployments
- Future centralized ERP architecture
- Regulatory compliance requirements

---

## Modeling Principles

1. **Business-Centric**: Entities represent business concepts, not technical implementations.
2. **Normalized**: Concepts are decomposed to eliminate redundancy.
3. **Extensible**: Design supports future business requirements without breaking changes.
4. **Consistent**: Naming and definitions follow established patterns.
5. **Auditable**: All transactional entities support complete audit trails.

---

# Organization Domain

## Company

**Business Definition**: A legal business entity that owns and operates one or more branches.

**Purpose**: Represents the highest level of organizational hierarchy for legal, financial, and administrative purposes.

**Ownership**: Enterprise-level, managed by System Administrators.

**Lifecycle**:
1. Created during initial system setup or enterprise expansion
2. Activated upon regulatory approval
3. May be suspended for compliance issues
4. Deactivated when business ceases operations

**Relationships**:
- Has many Branches
- Has many Users (employment relationship)
- Has many Roles (company-specific)
- Owns all data created within its boundaries

**Business Rules**:
- Company code must be unique across the entire system
- A company cannot be deleted if it has active branches or users
- At least one company must exist in the system
- Company status changes require executive approval
- All financial transactions roll up to company level for reporting

**Future Extensibility**:
- Support for multi-national companies with different legal entities
- Consolidated reporting across multiple companies
- Inter-company transactions

---

## Branch

**Business Definition**: A physical location or operational unit where business activities occur.

**Purpose**: Represents a specific pharmacy location, warehouse, or office where transactions are processed and inventory is held.

**Ownership**: Company-level, managed by Company Administrators.

**Lifecycle**:
1. Planned → Approved → Opened → Operating
2. May enter Maintenance mode temporarily
3. Can be Closed permanently

**Relationships**:
- Belongs to exactly one Company
- Has many Users assigned
- Holds Inventory Items
- Processes Sales Orders
- Receives Purchase Orders
- May have parent/child relationships for regional hierarchies

**Business Rules**:
- Branch code must be unique within its company
- A branch must belong to exactly one company
- Cannot delete a branch with existing inventory or transactions
- Only one branch per company can be designated as Head Office
- Each branch maintains its own inventory and cash drawers

**Future Extensibility**:
- Support for regional/zone hierarchies
- Virtual branches for online sales
- Mobile pharmacy units

---

## Warehouse

**Business Definition**: A dedicated storage facility for inventory, separate from retail counters.

**Purpose**: Manages bulk inventory storage, distribution to branches, and receiving from suppliers.

**Ownership**: Company-level or Branch-level depending on configuration.

**Lifecycle**:
1. Planned → Configured → Operational
2. May be expanded or reconfigured
3. Can be closed when no longer needed

**Relationships**:
- Associated with one Branch or Company
- Contains Inventory Items in bulk quantities
- Sources Purchase Order receipts
- Fulfills inter-branch transfers

**Business Rules**:
- Warehouse code must be unique within its scope
- A warehouse must be linked to a branch or company
- Inventory transfers require warehouse-to-warehouse documentation
- Warehouses do not process direct customer sales

**Future Extensibility**:
- Multi-zone warehouse management
- Automated picking systems integration
- Third-party logistics (3PL) integration

---

## Counter

**Business Definition**: A point-of-sale workstation within a branch where transactions are processed.

**Purpose**: Represents a specific POS terminal or sales counter for tracking transactions and cash handling.

**Ownership**: Branch-level, managed by Branch Managers.

**Lifecycle**:
1. Configured → Active → Inactive
2. May be reassigned to different users
3. Can be retired when hardware is replaced

**Relationships**:
- Belongs to one Branch
- Used by many Users (over time)
- Processes many Sales Orders
- Associated with Cash Drawers

**Business Rules**:
- Counter code must be unique within a branch
- Multiple counters can operate simultaneously in a branch
- Each transaction is attributed to a specific counter
- Counters can be temporarily disabled for maintenance

**Future Extensibility**:
- Mobile counter support (tablets, handheld devices)
- Self-service kiosk integration
- Queue management integration

---

## Cash Drawer

**Business Definition**: A physical or logical container for cash and payment instruments at a counter.

**Purpose**: Tracks cash movements, opening/closing balances, and discrepancies at the point of sale.

**Ownership**: Branch-level, managed by Branch Managers and Cashiers.

**Lifecycle**:
1. Opened with starting balance
2. Transactions recorded throughout shift
3. Closed with ending balance and reconciliation

**Relationships**:
- Assigned to one Counter
- Managed by one User (cashier) per shift
- Records many Cash Transactions
- Reconciled against Sales Orders

**Business Rules**:
- Each counter must have an assigned cash drawer
- Opening balance must be verified before starting shift
- All cash movements must be recorded
- Discrepancies must be documented and approved
- Cash drawer must be closed before user ends shift

**Future Extensibility**:
- Integration with electronic cash registers
- Automated cash counting devices
- Multi-currency drawer support

---

# Security Domain

## User

**Business Definition**: An individual person with access to the PharmaX system.

**Purpose**: Represents employees, contractors, or authorized personnel who interact with the system.

**Ownership**: Company-level, managed by HR and IT Administrators.

**Lifecycle**:
1. Onboarded → Account Created → Active
2. May be Suspended temporarily
3. Terminated → Account Disabled (soft delete)

**Relationships**:
- Employed by one Company
- Assigned to one or more Branches
- Granted many Roles
- Creates many Sessions
- Processes many Transactions

**Business Rules**:
- Username must be unique within the company
- Email must be unique across the system
- Password must meet complexity requirements
- Account locks after consecutive failed login attempts
- Users cannot be hard-deleted; only deactivated
- Every user must have at least one role assignment

**Future Extensibility**:
- Multi-factor authentication support
- Biometric authentication
- External identity provider integration (SSO)

---

## Role

**Business Definition**: A named collection of permissions that defines a job function.

**Purpose**: Enables role-based access control (RBAC) by grouping permissions logically.

**Ownership**: Company-level or System-level.

**Lifecycle**:
1. Defined → Approved → Active
2. May be modified (permissions added/removed)
3. Deprecated → Inactive (cannot delete if in use)

**Relationships**:
- Scoped to Company or System-wide
- Contains many Permissions
- Assigned to many Users
- May be limited to specific Branches

**Business Rules**:
- Role name must be unique within its scope
- System roles cannot be deleted or modified
- Roles cannot be deleted if assigned to users
- Every role must have at least one permission
- Role modifications are fully audited

**Future Extensibility**:
- Hierarchical roles (role inherits from role)
- Dynamic roles based on attributes
- Time-bound role assignments

---

## Permission

**Business Definition**: A granular authorization right to perform a specific action.

**Purpose**: Provides fine-grained access control at the operation level.

**Ownership**: System-level, defined by application code.

**Lifecycle**:
1. Defined in code → Deployed → Available
2. May be deprecated but never deleted

**Relationships**:
- Grouped into Categories
- Assigned to many Roles
- Associated with specific Features/Modules

**Business Rules**:
- Permission code must follow naming convention (MODULE.ACTION)
- System permissions cannot be deleted
- New permissions require code deployment
- Permissions are immutable once created

**Future Extensibility**:
- Attribute-based permissions
- Data-level permissions (row-level security)
- Conditional permissions based on context

---

## Session

**Business Definition**: An authenticated connection between a user and the system.

**Purpose**: Tracks active user sessions for security, auditing, and session management.

**Ownership**: System-level, managed by Authentication service.

**Lifecycle**:
1. Login → Session Created → Active
2. Periodic activity refresh
3. Logout or Timeout → Session Ended

**Relationships**:
- Belongs to one User
- Associated with one Branch (context)
- Linked to one Company (context)
- May be associated with a Counter

**Business Rules**:
- Users may have configurable concurrent session limits
- Sessions expire after period of inactivity
- Forced logout terminates all active sessions
- Session data retained for audit trail
- Sensitive actions require re-authentication

**Future Extensibility**:
- Session analytics and anomaly detection
- Geographic restrictions
- Device fingerprinting

---

# Product Domain

## Product

**Business Definition**: A pharmaceutical item in the master catalog available for sale or purchase.

**Purpose**: Defines the core product information independent of packaging or location.

**Ownership**: Enterprise-level (shared catalog) or Company-level.

**Lifecycle**:
1. Developed/Sourced → Cataloged → Active
2. May be reformulated or repackaged
3. Discontinued → No new orders allowed
4. Recalled → Immediate removal from sale

**Relationships**:
- Classified into one Category
- Manufactured by one Manufacturer
- Has many Product Variants
- Appears in many Inventory Items
- Referenced in Sales and Purchase Orders

**Business Rules**:
- SKU must be unique within the company
- Barcode (GTIN) must be unique globally
- Products cannot be deleted if referenced in transactions
- Discontinuation requires zero inventory or transfer plan
- Controlled substances require additional regulatory tracking
- Prescription products flag enforcement

**Future Extensibility**:
- Product lifecycle management workflows
- Recall management automation
- Integration with external drug databases

---

## Category

**Business Definition**: A hierarchical classification for organizing products.

**Purpose**: Enables product grouping for reporting, pricing, and navigation.

**Ownership**: Enterprise-level or Company-level.

**Lifecycle**:
1. Defined → Active
2. May be reorganized (parent changed)
3. Deactivated when obsolete

**Relationships**:
- May have one Parent Category (self-referential)
- Has many Child Categories
- Contains many Products

**Business Rules**:
- Category code must be unique
- Circular references in hierarchy prohibited
- Maximum depth may be enforced (e.g., 5 levels)
- Cannot delete category containing products
- Moving a category moves all descendants

**Future Extensibility**:
- Multi-dimensional categorization (tags)
- Seasonal or promotional categories
- Customer-facing vs internal categories

---

## Manufacturer

**Business Definition**: A company that produces pharmaceutical products.

**Purpose**: Tracks product origin for quality, recall, and supplier management.

**Ownership**: Enterprise-level or Company-level.

**Lifecycle**:
1. Qualified → Approved → Active
2. May be suspended for quality issues
3. Removed from approved list

**Relationships**:
- Produces many Products
- May also be a Supplier

**Business Rules**:
- Manufacturer code must be unique
- Cannot delete if manufacturing active products
- Quality incidents tracked per manufacturer
- Regulatory certifications maintained

**Future Extensibility**:
- Certification expiry tracking
- Country of origin tracking
- Manufacturing license management

---

## Generic

**Business Definition**: The non-proprietary name of a drug's active ingredient(s).

**Purpose**: Groups branded products by their therapeutic equivalent for substitution and formulary management.

**Ownership**: Enterprise-level.

**Lifecycle**:
1. Identified → Standardized → Active
2. Rarely changes

**Relationships**:
- Associated with many Brands
- Linked to many Products

**Business Rules**:
- Generic name follows international nomenclature standards
- One product maps to one generic
- Substitution rules based on generic equivalence

**Future Extensibility**:
- Therapeutic equivalence codes
- Formulary tier management
- Insurance coverage mapping

---

## Brand

**Business Definition**: A proprietary trade name under which a product is marketed.

**Purpose**: Identifies manufacturer-specific versions of generic drugs.

**Ownership**: Enterprise-level.

**Lifecycle**:
1. Registered → Active
2. May be discontinued by manufacturer

**Relationships**:
- Associated with one Generic
- Associated with one Manufacturer
- Applied to many Products

**Business Rules**:
- Brand names must be unique within manufacturer
- Trademark verification required
- Brand discontinuation affects product availability

---

## Unit

**Business Definition**: A standard measurement for quantity, dosing, or packaging.

**Purpose**: Enables consistent quantity tracking across different contexts.

**Ownership**: Enterprise-level.

**Lifecycle**:
1. Defined → Active
2. Rarely deactivated

**Relationships**:
- Used by many Products
- Used in Inventory tracking
- Used in Sales and Purchasing

**Business Rules**:
- Unit code must be unique (e.g., TAB, CAP, ML, GM)
- Conversion factors between related units
- Standard units preferred over custom units

**Future Extensibility**:
- Unit conversion engine
- Compound units (e.g., MG/ML)
- Region-specific unit variations

---

## Barcode

**Business Definition**: A machine-readable representation of product identification.

**Purpose**: Enables fast, accurate product identification at POS and in warehouse.

**Ownership**: Product-level attribute.

**Types Supported**:
- EAN-13 (international retail)
- UPC-A (North America)
- Code 128 (internal/logistics)
- DataMatrix/QR (pharmaceutical serialization)

**Business Rules**:
- Primary barcode must be unique globally
- Products may have multiple barcodes (different markets)
- Barcode format validation enforced
- Pharmaceutical serialization compliance (DSCSA, FMD)

**Future Extensibility**:
- RFID tag support
- 2D barcode for batch/expiry encoding
- GS1 Digital Link integration

---

## Batch

**Business Definition**: A specific production lot of a product with shared characteristics.

**Purpose**: Enables traceability for quality control, recalls, and expiry management.

**Ownership**: Inventory-level attribute.

**Lifecycle**:
1. Received → Quarantine (optional) → Released
2. Sold/Used → Depleted
3. Expired → Disposed

**Relationships**:
- Associated with one Product
- Tracked in Inventory Items
- Referenced in Sales and Purchase transactions

**Business Rules**:
- Batch number unique per product per manufacturer
- Batch receipt date recorded
- Expiry date mandatory for pharmaceuticals
- First-Expiry-First-Out (FEFO) picking recommended
- Full traceability from supplier to customer

**Future Extensibility**:
- Serial number tracking per unit
- Blockchain-based traceability
- Automated recall execution

---

## Expiry

**Business Definition**: The date after which a product should not be sold or used.

**Purpose**: Ensures patient safety and regulatory compliance.

**Ownership**: Batch-level attribute.

**Business Rules**:
- Expiry date mandatory for all pharmaceutical products
- Products cannot be sold past expiry date
- Automated alerts for approaching expiry (configurable thresholds)
- Expired products automatically quarantined
- Disposal documentation required

**Future Extensibility**:
- Shelf-life calculation from manufacturing date
- Extended expiry with stability testing
- Donation workflow for near-expiry products

---

## Tax

**Business Definition**: A government-imposed levy on transactions.

**Purpose**: Calculates and tracks tax obligations for sales and purchases.

**Ownership**: Company-level or Region-level.

**Lifecycle**:
1. Defined by regulation → Configured → Active
2. Rate changes effective dated
3. May be repealed or replaced

**Relationships**:
- Applied to Products (tax category)
- Applied to Transactions
- Reported to authorities

**Business Rules**:
- Tax rates effective-dated for historical accuracy
- Different rates per product category
- Tax-exempt customers require documentation
- Compound taxes supported (e.g., VAT + local tax)

**Future Extensibility**:
- Integration with tax calculation services
- Multi-jurisdiction support
- Automated tax filing

---

# Inventory Domain

## Inventory Item

**Business Definition**: A specific quantity of a product at a specific location with specific batch attributes.

**Purpose**: Tracks stock levels, costs, and status at the most granular level.

**Ownership**: Branch-level or Warehouse-level.

**Lifecycle**:
1. Received → Available
2. Reserved → Committed
3. Sold/Used → Depleted
4. Damaged/Expired → Adjusted out

**Relationships**:
- Located at one Branch/Warehouse
- References one Product
- References one Batch
- Subject to many Stock Movements

**Business Rules**:
- Quantity cannot be negative
- Available = On Hand - Reserved - Quarantined
- Batch number and expiry mandatory for pharmaceuticals
- Cost tracked per batch (FIFO/FEFO valuation)
- Location bin tracking optional but recommended

**Future Extensibility**:
- Multi-location bin management
- Consignment inventory support
- Vendor-managed inventory (VMI)

---

## Stock Ledger

**Business Definition**: An immutable record of every inventory change.

**Purpose**: Provides complete audit trail and supports inventory reconciliation.

**Ownership**: Branch-level or Company-level.

**Lifecycle**:
1. Transaction occurs → Ledger entry created
2. Never modified or deleted

**Relationships**:
- References one Inventory Item
- Caused by one Transaction (Sale, Purchase, Adjustment, Transfer)
- Recorded by one User

**Business Rules**:
- Every inventory change creates a ledger entry
- Ledger entries are immutable
- Running balance calculated from ledger
- Audit trail includes timestamp, user, reason

**Future Extensibility**:
- Real-time analytics on ledger stream
- Predictive reorder suggestions
- Anomaly detection for shrinkage

---

## Stock Movement

**Business Definition**: A physical or logical transfer of inventory from one state to another.

**Purpose**: Documents the flow of goods through the supply chain.

**Types**:
- Receipt (from supplier)
- Sale (to customer)
- Transfer (between locations)
- Adjustment (correction)
- Damage/Loss
- Return (from customer)
- Return (to supplier)

**Relationships**:
- Moves inventory from/to locations
- Linked to source document (PO, SO, Transfer Order)

**Business Rules**:
- Every movement requires authorization level appropriate to type
- Source document reference mandatory
- Quantity moved cannot exceed available
- FEFO (First-Expiry-First-Out) enforced for picking

---

## Adjustment

**Business Definition**: A correction to inventory records to match physical count.

**Purpose**: Reconciles system inventory with actual stock.

**Ownership**: Branch-level, requires approval.

**Lifecycle**:
1. Discrepancy identified → Adjustment requested
2. Reviewed → Approved/Rejected
3. Executed → Inventory updated

**Relationships**:
- Affects many Inventory Items
- Approved by Manager
- Recorded in Stock Ledger

**Business Rules**:
- Adjustments over threshold require higher approval
- Reason code mandatory
- Frequent adjustments trigger investigation
- Year-end adjustments may have special handling

---

## Transfer

**Business Definition**: Movement of inventory between branches or warehouses.

**Purpose**: Balances stock across locations and fulfills inter-branch requests.

**Ownership**: Company-level (coordinates between branches).

**Lifecycle**:
1. Requested → Approved
2. Picked → Shipped
3. Received → Completed

**Relationships**:
- From one Branch/Warehouse
- To one Branch/Warehouse
- Creates two Stock Movements (out and in)

**Business Rules**:
- Transfer requires both sending and receiving confirmation
- In-transit inventory tracked separately
- Discrepancies handled via adjustment workflow
- Transfer pricing may differ from cost

---

## Damage

**Business Definition**: Inventory that is no longer sellable due to physical harm.

**Purpose**: Tracks losses and supports insurance claims.

**Ownership**: Branch-level.

**Lifecycle**:
1. Identified → Quarantined
2. Documented → Approved for disposal
3. Disposed → Written off

**Relationships**:
- References damaged Inventory Items
- Requires photographic evidence (optional)
- May link to insurance claim

**Business Rules**:
- Damage reason code mandatory
- Approval required before write-off
- High-value damage requires investigation
- Regulatory disposal procedures followed

---

## Opening Stock

**Business Definition**: Initial inventory quantities recorded when starting system or new location.

**Purpose**: Establishes baseline for inventory tracking.

**Ownership**: Branch-level.

**Lifecycle**:
1. Physical count conducted
2. Quantities and values entered
3. Approved → Loaded as opening balances

**Business Rules**:
- Opening stock locked after first transaction
- Historical date set appropriately
- Valuation method documented
- Audit trail preserved

---

# Purchasing Domain

## Supplier

**Business Definition**: A vendor that provides products to the pharmacy.

**Purpose**: Manages vendor relationships for procurement.

**Ownership**: Company-level.

**Lifecycle**:
1. Qualified → Approved → Active
2. Performance monitored
3. May be Blocked or Deactivated

**Relationships**:
- Supplies many Products
- Receives many Purchase Orders
- Has payment terms and history

**Business Rules**:
- Supplier code must be unique
- Due diligence required before approval
- Cannot delete if outstanding orders exist
- Performance metrics tracked (delivery time, quality)
- Blocked suppliers cannot receive new orders

**Future Extensibility**:
- Supplier portal for order collaboration
- Electronic data interchange (EDI)
- Automated replenishment agreements

---

## Purchase Order

**Business Definition**: A commercial document issued to a supplier requesting products.

**Purpose**: Formalizes purchasing intent and serves as a contract.

**Ownership**: Branch-level or Company-level.

**Lifecycle**:
1. Draft → Submitted
2. Approved (if required) → Sent to Supplier
3. Partially Received → Completed
4. May be Cancelled

**Relationships**:
- Issued by one Branch
- Sent to one Supplier
- Contains many Purchase Order Lines
- Received via Goods Receipt

**Business Rules**:
- PO number unique and sequential
- Approval workflow based on amount thresholds
- Cannot receive more than ordered without amendment
- Price variances flagged on receipt
- Closed when fully received or cancelled

**Future Extensibility**:
- Electronic transmission to suppliers
- Blanket orders with release calls
- Consignment order tracking

---

## Purchase Invoice

**Business Definition**: A supplier's bill for goods received.

**Purpose**: Records financial obligation for payment processing.

**Ownership**: Company-level (Accounts Payable).

**Lifecycle**:
1. Received → Matched to PO and Goods Receipt
2. Approved → Scheduled for Payment
3. Paid → Closed

**Relationships**:
- References one or more Purchase Orders
- References Goods Receipts
- Creates Supplier Ledger entry

**Business Rules**:
- Three-way match required (PO, GRN, Invoice)
- Variances require approval
- Duplicate invoice detection
- Payment terms determine due date

---

## Goods Receipt

**Business Definition**: Documentation of products received from supplier.

**Purpose**: Updates inventory and confirms order fulfillment.

**Ownership**: Branch-level (Warehouse/Receiving).

**Lifecycle**:
1. Shipment arrives → Inspected
2. Quantities verified → Receipt recorded
3. Inventory updated → PO updated

**Relationships**:
- References one Purchase Order
- Creates Inventory Items
- May trigger Quality Inspection

**Business Rules**:
- Receipt quantity cannot exceed order quantity (without amendment)
- Batch and expiry data captured at receipt
- Quality inspection may quarantine receipt
- Partial receipts allowed and tracked

---

## Supplier Return

**Business Definition**: Products returned to supplier due to defects, expiry, or overstock.

**Purpose**: Manages reverse logistics and credit recovery.

**Ownership**: Branch-level, requires approval.

**Lifecycle**:
1. Return requested → Approved
2. Picked → Shipped to Supplier
3. Credit Note received → Completed

**Relationships**:
- References original Purchase Order or Goods Receipt
- Reduces Inventory
- Creates Supplier Ledger credit

**Business Rules**:
- Return authorization from supplier required
- Reason code mandatory
- Credit tracking until received
- Regulatory compliance for controlled substances

---

# Sales Domain

## Customer

**Business Definition**: An individual or organization that purchases products.

**Purpose**: Maintains customer information for sales, marketing, and service.

**Ownership**: Branch-level or Company-level.

**Lifecycle**:
1. Registered → Active
2. May be enrolled in loyalty program
3. May be Blocked for cause
4. Inactive after prolonged no activity

**Relationships**:
- Places many Sales Orders
- Makes many Payments
- May have Prescription records
- Assigned to home Branch (optional)

**Business Rules**:
- Customer code must be unique
- Contact information validated
- Privacy regulations compliance (HIPAA, GDPR)
- Blocked customers cannot make purchases
- Credit limit enforcement configurable

**Future Extensibility**:
- Customer portal for order history
- Prescription refill reminders
- Health profile integration

---

## Sales Order

**Business Definition**: A record of products sold to a customer.

**Purpose**: Documents the sales transaction for fulfillment, invoicing, and reporting.

**Ownership**: Branch-level.

**Lifecycle**:
1. Created (Draft/Quote)
2. Confirmed → Completed
3. Invoiced → Paid
4. May be Voided or Refunded

**Types**:
- POS Sale (immediate)
- Order (future pickup/delivery)
- Quote (estimate)

**Relationships**:
- Processed at one Branch
- Served by one Counter
- Associated with one Customer (optional for walk-in)
- Contains many Sales Order Lines
- Receives many Payments

**Business Rules**:
- Order number unique and sequential per branch
- Invoice generated on completion
- Inventory reserved on order creation
- Prescription products require valid prescription
- Voided orders cannot be modified
- Refunds require manager approval

**Future Extensibility**:
- Delivery scheduling
- Subscription/refill automation
- Integration with delivery services

---

## Sales Invoice

**Business Definition**: A formal request for payment for goods sold.

**Purpose**: Legal document for accounting and tax purposes.

**Ownership**: Branch-level.

**Lifecycle**:
1. Generated from Sales Order
2. Delivered to Customer
3. Paid → Closed
4. May have Credit Note issued

**Relationships**:
- References one Sales Order
- May span multiple Payments
- Creates Customer Ledger entry

**Business Rules**:
- Invoice number unique and sequential
- Tax details clearly shown
- Sequential numbering required by law
- Duplicates clearly marked

---

## Sales Return

**Business Definition**: Products returned by a customer for refund or exchange.

**Purpose**: Manages reverse logistics and customer satisfaction.

**Ownership**: Branch-level, requires approval.

**Lifecycle**:
1. Return requested → Inspected
2. Approved → Credit issued
3. Inventory updated (if resellable)

**Relationships**:
- References original Sales Order
- Creates Payment (refund) or Credit Note
- May create new Inventory Item

**Business Rules**:
- Return policy enforcement (time limits, condition)
- Original payment method preferred for refund
- Prescription returns restricted by regulation
- Restocking fee may apply

---

## Payment

**Business Definition**: A transfer of funds from customer to pharmacy.

**Purpose**: Records settlement of sales invoices.

**Ownership**: Branch-level.

**Types**:
- Cash
- Credit/Debit Card
- Insurance Claim
- Account/Credit
- Voucher/Coupon
- Bank Transfer

**Relationships**:
- Applied to one or more Sales Invoices
- Processed at one Branch
- Recorded by one User
- Deposited to Cash Drawer or Bank

**Business Rules**:
- Payment amount cannot exceed invoice balance (unless overpayment tracked)
- Change given for cash payments
- Card transactions require authorization
- Insurance claims tracked separately
- Payment reconciliation required daily

**Future Extensibility**:
- Digital wallet integration
- Buy-now-pay-later (BNPL)
- Cryptocurrency acceptance

---

# Finance Domain

## Cash Book

**Business Definition**: A record of all cash receipts and disbursements.

**Purpose**: Tracks cash flow and supports bank reconciliation.

**Ownership**: Branch-level or Company-level.

**Lifecycle**:
1. Daily transactions recorded
2. End-of-day reconciliation
3. Period closed

**Relationships**:
- Summarizes Cash Drawer activity
- Links to Bank deposits
- Feeds General Ledger

**Business Rules**:
- All cash movements recorded
- Daily balancing required
- Discrepancies investigated
- Supervisor sign-off required

---

## Bank Book

**Business Definition**: A record of all bank transactions.

**Purpose**: Tracks bank balances and supports reconciliation.

**Ownership**: Company-level.

**Lifecycle**:
1. Transactions recorded
2. Monthly reconciliation
3. Period closed

**Relationships**:
- Links to Cash Book (deposits)
- Records loan payments
- Records supplier payments
- Records customer receipts

**Business Rules**:
- Bank reconciliation monthly minimum
- Dual authorization for large transfers
- Bank fees tracked
- Interest income/expense recorded

---

## Expense

**Business Definition**: A cost incurred in the course of business operations.

**Purpose**: Tracks operational costs for profitability analysis.

**Ownership**: Company-level.

**Categories**:
- Rent
- Utilities
- Salaries
- Supplies
- Marketing
- Professional fees
- Depreciation

**Relationships**:
- Charged to one Branch or Company
- May be linked to Supplier invoice
- Recorded in General Ledger

**Business Rules**:
- Expense approval workflow based on amount
- Budget variance tracking
- Receipt/invoice attachment required
- Capital vs expense classification

---

## Income

**Business Definition**: Revenue earned from business activities.

**Purpose**: Tracks revenue sources for profitability analysis.

**Ownership**: Company-level.

**Categories**:
- Product Sales
- Service Revenue
- Interest Income
- Other Income

**Relationships**:
- Generated from Sales
- May be from other sources
- Recorded in General Ledger

**Business Rules**:
- Revenue recognition principles followed
- Accrual basis accounting
- Deferred revenue tracked

---

## Customer Ledger

**Business Definition**: A detailed record of all transactions with a customer.

**Purpose**: Tracks amounts owed by customers (Accounts Receivable).

**Ownership**: Company-level.

**Lifecycle**:
1. Invoice created → Balance increases
2. Payment received → Balance decreases
3. Aging tracked for collections

**Relationships**:
- One ledger per Customer
- Summarizes Invoices and Payments
- Feeds aging reports

**Business Rules**:
- Real-time balance calculation
- Aging buckets configurable
- Credit hold enforcement
- Write-off requires approval

---

## Supplier Ledger

**Business Definition**: A detailed record of all transactions with a supplier.

**Purpose**: Tracks amounts owed to suppliers (Accounts Payable).

**Ownership**: Company-level.

**Lifecycle**:
1. Invoice received → Balance increases
2. Payment made → Balance decreases
3. Aging tracked for payment planning

**Relationships**:
- One ledger per Supplier
- Summarizes Purchase Invoices and Payments
- Feeds aging reports

**Business Rules**:
- Payment term enforcement
- Early payment discount capture
- Dispute tracking
- 1099 reporting (where applicable)

---

# Cross-Domain Relationships

## Aggregate Boundaries

| Aggregate Root | Entities Included | Boundary Type |
|----------------|-------------------|---------------|
| Company | Branch, Warehouse, Counter | Organizational |
| User | Role, Permission, Session | Security |
| Product | Category, Variant, Barcode | Catalog |
| Inventory Item | Batch, Expiry, Stock Ledger | Inventory |
| Purchase Order | PO Line, Goods Receipt | Procurement |
| Sales Order | SO Line, Payment, Invoice | Sales |
| Customer | Customer Ledger | CRM |
| Supplier | Supplier Ledger | SRM |

## Module Ownership Matrix

| Entity | Primary Module | Secondary Modules |
|--------|----------------|-------------------|
| Company | Administration | All |
| Branch | Administration | All |
| User | Users | Authentication |
| Role | Authorization | Users |
| Permission | Authorization | All |
| Product | Product Management | Inventory, Sales, Purchasing |
| Category | Product Management | Reporting |
| Inventory Item | Inventory | Sales, Purchasing |
| Purchase Order | Purchasing | Inventory, Finance |
| Sales Order | Sales (POS) | Inventory, Finance |
| Customer | Sales | Finance |
| Supplier | Purchasing | Finance |

---

# Glossary

| Term | Definition |
|------|------------|
| Aggregate | A cluster of domain objects treated as a unit |
| Aggregate Root | The main entity that controls access to the aggregate |
| Entity | An object with a distinct identity that persists over time |
| Value Object | An object defined by its attributes, not identity |
| Repository | A pattern for accessing aggregates from storage |
| Unit of Work | A pattern for managing transaction boundaries |
| FEFO | First-Expiry-First-Out inventory rotation |
| FIFO | First-In-First-Out inventory rotation |
| RBAC | Role-Based Access Control |
| SKU | Stock Keeping Unit |
| GTIN | Global Trade Item Number |
| DSCSA | Drug Supply Chain Security Act |
| FMD | Falsified Medicines Directive |

---

# Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0003 | Architecture Team | Initial CDM release |

---

# References

- [Domain Model](03-domain-model.md)
- [Module Map](02-module-map.md)
- [Database Standards](12-database-standards.md)
- ADR-0005: Why Repository Pattern + Unit of Work
