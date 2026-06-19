-- ============================================================================
-- PharmaX Enterprise Database Schema
-- Module: Core (Organization & Security)
-- Version: 1.0
-- Created: WO-0003
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Companies Table
-- ----------------------------------------------------------------------------
CREATE TABLE core.Companies (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    Code                    NVARCHAR(50)    NOT NULL,
    Name                    NVARCHAR(200)   NOT NULL,
    TradeName               NVARCHAR(200)   NULL,
    TaxIdentificationNumber NVARCHAR(50)    NULL,
    RegistrationNumber      NVARCHAR(50)    NULL,
    Status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_Companies_Status DEFAULT 'Active',
    IsHeadOffice            BIT             NOT NULL CONSTRAINT DF_Companies_IsHeadOffice DEFAULT 0,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Companies_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Companies_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Companies PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT UQ_Companies_Code UNIQUE (Code),
    CONSTRAINT CK_Companies_Status_Valid CHECK (Status IN ('Active', 'Inactive', 'Suspended'))
);

CREATE INDEX IX_Companies_Status ON core.Companies(Status) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- Branches Table
-- ----------------------------------------------------------------------------
CREATE TABLE core.Branches (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    CompanyId               BIGINT          NOT NULL,
    Code                    NVARCHAR(50)    NOT NULL,
    Name                    NVARCHAR(200)   NOT NULL,
    Type                    NVARCHAR(20)    NOT NULL,
    AddressLine1            NVARCHAR(200)   NULL,
    AddressLine2            NVARCHAR(200)   NULL,
    City                    NVARCHAR(100)   NULL,
    StateProvince           NVARCHAR(100)   NULL,
    Country                 NVARCHAR(100)   NULL,
    PostalCode              NVARCHAR(20)    NULL,
    PhoneNumber             NVARCHAR(50)    NULL,
    Email                   NVARCHAR(100)   NULL,
    OperatingHours          NVARCHAR(200)   NULL,
    Status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_Branches_Status DEFAULT 'Active',
    IsHeadOffice            BIT             NOT NULL CONSTRAINT DF_Branches_IsHeadOffice DEFAULT 0,
    ParentBranchId          BIGINT          NULL,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Branches_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Branches_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Branches PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_Branches_Companies FOREIGN KEY (CompanyId) REFERENCES core.Companies(Id) ON DELETE CASCADE,
    CONSTRAINT FK_Branches_ParentBranch FOREIGN KEY (ParentBranchId) REFERENCES core.Branches(Id),
    CONSTRAINT UQ_Branches_Company_Code UNIQUE (CompanyId, Code),
    CONSTRAINT CK_Branches_Type_Valid CHECK (Type IN ('Retail', 'Warehouse', 'Office', 'Distribution')),
    CONSTRAINT CK_Branches_Status_Valid CHECK (Status IN ('Active', 'Inactive', 'Maintenance', 'Closed'))
);

CREATE INDEX IX_Branches_Company ON core.Branches(CompanyId) WHERE IsDeleted = 0;
CREATE INDEX IX_Branches_Status ON core.Branches(Status) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- Warehouses Table
-- ----------------------------------------------------------------------------
CREATE TABLE core.Warehouses (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    BranchId                BIGINT          NOT NULL,
    Code                    NVARCHAR(50)    NOT NULL,
    Name                    NVARCHAR(200)   NOT NULL,
    Type                    NVARCHAR(20)    NOT NULL,
    AddressLine1            NVARCHAR(200)   NULL,
    City                    NVARCHAR(100)   NULL,
    Status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_Warehouses_Status DEFAULT 'Active',
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Warehouses_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Warehouses_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Warehouses PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_Warehouses_Branches FOREIGN KEY (BranchId) REFERENCES core.Branches(Id),
    CONSTRAINT UQ_Warehouses_Branch_Code UNIQUE (BranchId, Code),
    CONSTRAINT CK_Warehouses_Type_Valid CHECK (Type IN ('Main', 'ColdStorage', 'Quarantine', 'Returns')),
    CONSTRAINT CK_Warehouses_Status_Valid CHECK (Status IN ('Active', 'Inactive', 'Full'))
);

CREATE INDEX IX_Warehouses_Branch ON core.Warehouses(BranchId) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- Counters Table
-- ----------------------------------------------------------------------------
CREATE TABLE core.Counters (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    BranchId                BIGINT          NOT NULL,
    Code                    NVARCHAR(50)    NOT NULL,
    Name                    NVARCHAR(200)   NOT NULL,
    Status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_Counters_Status DEFAULT 'Active',
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Counters_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Counters_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Counters PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_Counters_Branches FOREIGN KEY (BranchId) REFERENCES core.Branches(Id),
    CONSTRAINT UQ_Counters_Branch_Code UNIQUE (BranchId, Code),
    CONSTRAINT CK_Counters_Status_Valid CHECK (Status IN ('Active', 'Inactive', 'Maintenance'))
);

CREATE INDEX IX_Counters_Branch ON core.Counters(BranchId) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- CashDrawers Table
-- ----------------------------------------------------------------------------
CREATE TABLE core.CashDrawers (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    CounterId               BIGINT          NOT NULL,
    OpeningBalance          DECIMAL(18,4)   NOT NULL CONSTRAINT DF_CashDrawers_OpeningBalance DEFAULT 0,
    CurrentBalance          DECIMAL(18,4)   NOT NULL CONSTRAINT DF_CashDrawers_CurrentBalance DEFAULT 0,
    Status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_CashDrawers_Status DEFAULT 'Closed',
    OpenedBy                INT             NULL,
    OpenedDate              DATETIME2(0)    NULL,
    ClosedBy                INT             NULL,
    ClosedDate              DATETIME2(0)    NULL,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_CashDrawers_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_CashDrawers_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_CashDrawers PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_CashDrawers_Counters FOREIGN KEY (CounterId) REFERENCES core.Counters(Id),
    CONSTRAINT CK_CashDrawers_Status_Valid CHECK (Status IN ('Open', 'Closed', 'Reconciling', 'Discrepancy'))
);

CREATE INDEX IX_CashDrawers_Counter ON core.CashDrawers(CounterId) WHERE IsDeleted = 0;
CREATE INDEX IX_CashDrawers_Status ON core.CashDrawers(Status) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- Users Table
-- ----------------------------------------------------------------------------
CREATE TABLE core.Users (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    CompanyId               BIGINT          NOT NULL,
    Username                NVARCHAR(100)   NOT NULL,
    Email                   NVARCHAR(256)   NOT NULL,
    PasswordHash            NVARCHAR(512)   NOT NULL,
    FirstName               NVARCHAR(100)   NOT NULL,
    LastName                NVARCHAR(100)   NOT NULL,
    PhoneNumber             NVARCHAR(50)    NULL,
    EmployeeId              NVARCHAR(50)    NULL,
    Department              NVARCHAR(100)   NULL,
    JobTitle                NVARCHAR(100)   NULL,
    Status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_Users_Status DEFAULT 'Active',
    LastLoginDate           DATETIME2(0)    NULL,
    PasswordChangedDate     DATETIME2(0)    NULL,
    FailedLoginAttempts     INT             NOT NULL CONSTRAINT DF_Users_FailedLoginAttempts DEFAULT 0,
    LockoutEndDate          DATETIME2(0)    NULL,
    DefaultBranchId         BIGINT          NULL,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Users_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Users_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_Users_Companies FOREIGN KEY (CompanyId) REFERENCES core.Companies(Id),
    CONSTRAINT FK_Users_DefaultBranch FOREIGN KEY (DefaultBranchId) REFERENCES core.Branches(Id),
    CONSTRAINT UQ_Users_Company_Username UNIQUE (CompanyId, Username),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT CK_Users_Status_Valid CHECK (Status IN ('Active', 'Suspended', 'Terminated', 'Locked'))
);

CREATE INDEX IX_Users_Company ON core.Users(CompanyId) WHERE IsDeleted = 0;
CREATE INDEX IX_Users_Status ON core.Users(Status) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- Roles Table
-- ----------------------------------------------------------------------------
CREATE TABLE core.Roles (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    CompanyId               BIGINT          NULL,
    Name                    NVARCHAR(100)   NOT NULL,
    Description             NVARCHAR(500)   NULL,
    BranchId                BIGINT          NULL,
    IsSystemRole            BIT             NOT NULL CONSTRAINT DF_Roles_IsSystemRole DEFAULT 0,
    IsLocked                BIT             NOT NULL CONSTRAINT DF_Roles_IsLocked DEFAULT 0,
    Status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_Roles_Status DEFAULT 'Active',
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Roles_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Roles_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Roles PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_Roles_Companies FOREIGN KEY (CompanyId) REFERENCES core.Companies(Id),
    CONSTRAINT FK_Roles_Branches FOREIGN KEY (BranchId) REFERENCES core.Branches(Id),
    CONSTRAINT UQ_Roles_Company_Name UNIQUE (CompanyId, Name),
    CONSTRAINT CK_Roles_Status_Valid CHECK (Status IN ('Active', 'Inactive'))
);

CREATE INDEX IX_Roles_Company ON core.Roles(CompanyId) WHERE IsDeleted = 0;
CREATE INDEX IX_Roles_Status ON core.Roles(Status) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- Permissions Table
-- ----------------------------------------------------------------------------
CREATE TABLE core.Permissions (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    Code                    NVARCHAR(100)   NOT NULL,
    Name                    NVARCHAR(200)   NOT NULL,
    Description             NVARCHAR(500)   NULL,
    Category                NVARCHAR(100)   NOT NULL,
    IsSystem                BIT             NOT NULL CONSTRAINT DF_Permissions_IsSystem DEFAULT 1,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Permissions_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Permissions_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Permissions PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT UQ_Permissions_Code UNIQUE (Code),
    CONSTRAINT CK_Permissions_IsSystem CHECK (IsSystem = 1) -- System permissions cannot be modified
);

CREATE INDEX IX_Permissions_Category ON core.Permissions(Category) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- UserRoles Association Table
-- ----------------------------------------------------------------------------
CREATE TABLE core.UserRoles (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    UserId                  BIGINT          NOT NULL,
    RoleId                  BIGINT          NOT NULL,
    CompanyId               BIGINT          NOT NULL,
    BranchId                BIGINT          NULL,
    GrantedBy               INT             NOT NULL,
    GrantedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_UserRoles_GrantedDate DEFAULT SYSUTCDATETIME(),
    ExpiryDate              DATETIME2(0)    NULL,
    IsActive                BIT             NOT NULL CONSTRAINT DF_UserRoles_IsActive DEFAULT 1,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_UserRoles_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_UserRoles_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_UserRoles PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES core.Users(Id),
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES core.Roles(Id),
    CONSTRAINT FK_UserRoles_Companies FOREIGN KEY (CompanyId) REFERENCES core.Companies(Id),
    CONSTRAINT FK_UserRoles_Branches FOREIGN KEY (BranchId) REFERENCES core.Branches(Id),
    CONSTRAINT UQ_UserRoles_User_Role_Branch UNIQUE (UserId, RoleId, BranchId)
);

CREATE INDEX IX_UserRoles_UserId ON core.UserRoles(UserId) WHERE IsDeleted = 0;
CREATE INDEX IX_UserRoles_RoleId ON core.UserRoles(RoleId) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- RolePermissions Association Table
-- ----------------------------------------------------------------------------
CREATE TABLE core.RolePermissions (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    RoleId                  BIGINT          NOT NULL,
    PermissionId            BIGINT          NOT NULL,
    GrantedBy               INT             NOT NULL,
    GrantedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_RolePermissions_GrantedDate DEFAULT SYSUTCDATETIME(),
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_RolePermissions_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_RolePermissions_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_RolePermissions PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_RolePermissions_Roles FOREIGN KEY (RoleId) REFERENCES core.Roles(Id),
    CONSTRAINT FK_RolePermissions_Permissions FOREIGN KEY (PermissionId) REFERENCES core.Permissions(Id),
    CONSTRAINT UQ_RolePermissions_Role_Permission UNIQUE (RoleId, PermissionId)
);

CREATE INDEX IX_RolePermissions_RoleId ON core.RolePermissions(RoleId) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- Sessions Table
-- ----------------------------------------------------------------------------
CREATE TABLE core.Sessions (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    UserId                  BIGINT          NOT NULL,
    Token                   NVARCHAR(512)   NOT NULL,
    BranchId                BIGINT          NULL,
    CompanyId               BIGINT          NOT NULL,
    CounterId               BIGINT          NULL,
    IPAddress               NVARCHAR(45)    NULL,
    UserAgent               NVARCHAR(500)   NULL,
    LoginTime               DATETIME2(0)    NOT NULL CONSTRAINT DF_Sessions_LoginTime DEFAULT SYSUTCDATETIME(),
    LastActivityTime        DATETIME2(0)    NOT NULL,
    ExpiryTime              DATETIME2(0)    NOT NULL,
    LogoutTime              DATETIME2(0)    NULL,
    Status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_Sessions_Status DEFAULT 'Active',
    TerminationReason       NVARCHAR(200)   NULL,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Sessions_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Sessions_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Sessions PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_Sessions_Users FOREIGN KEY (UserId) REFERENCES core.Users(Id),
    CONSTRAINT FK_Sessions_Branches FOREIGN KEY (BranchId) REFERENCES core.Branches(Id),
    CONSTRAINT FK_Sessions_Companies FOREIGN KEY (CompanyId) REFERENCES core.Companies(Id),
    CONSTRAINT FK_Sessions_Counters FOREIGN KEY (CounterId) REFERENCES core.Counters(Id),
    CONSTRAINT UQ_Sessions_Token UNIQUE (Token),
    CONSTRAINT CK_Sessions_Status_Valid CHECK (Status IN ('Active', 'Expired', 'Terminated', 'LoggedOut'))
);

CREATE INDEX IX_Sessions_UserId ON core.Sessions(UserId) WHERE IsDeleted = 0;
CREATE INDEX IX_Sessions_Token ON core.Sessions(Token) WHERE Status = 'Active' AND IsDeleted = 0;
CREATE INDEX IX_Sessions_Expiry ON core.Sessions(ExpiryTime) WHERE Status = 'Active' AND IsDeleted = 0;
