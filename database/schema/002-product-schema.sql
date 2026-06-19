-- ============================================================================
-- PharmaX Enterprise Database Schema
-- Module: Product (Product Catalog)
-- Version: 1.0
-- Created: WO-0003
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Categories Table
-- ----------------------------------------------------------------------------
CREATE TABLE product.Categories (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    CompanyId               BIGINT          NOT NULL,
    Code                    NVARCHAR(50)    NOT NULL,
    Name                    NVARCHAR(200)   NOT NULL,
    Description             NVARCHAR(500)   NULL,
    ParentCategoryId        BIGINT          NULL,
    Level                   INT             NOT NULL CONSTRAINT DF_Categories_Level DEFAULT 0,
    SortOrder               INT             NOT NULL CONSTRAINT DF_Categories_SortOrder DEFAULT 0,
    IsActive                BIT             NOT NULL CONSTRAINT DF_Categories_IsActive DEFAULT 1,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Categories_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Categories_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Categories PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_Categories_Companies FOREIGN KEY (CompanyId) REFERENCES core.Companies(Id),
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentCategoryId) REFERENCES product.Categories(Id),
    CONSTRAINT UQ_Categories_Company_Code UNIQUE (CompanyId, Code),
    CONSTRAINT CK_Categories_Level_Valid CHECK (Level BETWEEN 0 AND 10)
);

CREATE INDEX IX_Categories_Company ON product.Categories(CompanyId) WHERE IsDeleted = 0;
CREATE INDEX IX_Categories_Parent ON product.Categories(ParentCategoryId) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- Manufacturers Table
-- ----------------------------------------------------------------------------
CREATE TABLE product.Manufacturers (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    CompanyId               BIGINT          NOT NULL,
    Code                    NVARCHAR(50)    NOT NULL,
    Name                    NVARCHAR(200)   NOT NULL,
    ContactPerson           NVARCHAR(200)   NULL,
    Email                   NVARCHAR(100)   NULL,
    PhoneNumber             NVARCHAR(50)    NULL,
    AddressLine1            NVARCHAR(200)   NULL,
    City                    NVARCHAR(100)   NULL,
    Country                 NVARCHAR(100)   NULL,
    TaxIdentificationNumber NVARCHAR(50)    NULL,
    Status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_Manufacturers_Status DEFAULT 'Active',
    IsApproved              BIT             NOT NULL CONSTRAINT DF_Manufacturers_IsApproved DEFAULT 0,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Manufacturers_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Manufacturers_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Manufacturers PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_Manufacturers_Companies FOREIGN KEY (CompanyId) REFERENCES core.Companies(Id),
    CONSTRAINT UQ_Manufacturers_Company_Code UNIQUE (CompanyId, Code),
    CONSTRAINT CK_Manufacturers_Status_Valid CHECK (Status IN ('Active', 'Inactive', 'Suspended', 'Blocked'))
);

CREATE INDEX IX_Manufacturers_Company ON product.Manufacturers(CompanyId) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- Generics Table
-- ----------------------------------------------------------------------------
CREATE TABLE product.Generics (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    Code                    NVARCHAR(50)    NOT NULL,
    Name                    NVARCHAR(200)   NOT NULL,
    Description             NVARCHAR(500)   NULL,
    ATCCode                 NVARCHAR(50)    NULL,
    IsActive                BIT             NOT NULL CONSTRAINT DF_Generics_IsActive DEFAULT 1,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Generics_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Generics_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Generics PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT UQ_Generics_Code UNIQUE (Code),
    CONSTRAINT UQ_Generics_Name UNIQUE (Name)
);

-- ----------------------------------------------------------------------------
-- Brands Table
-- ----------------------------------------------------------------------------
CREATE TABLE product.Brands (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    GenericId               BIGINT          NOT NULL,
    ManufacturerId          BIGINT          NOT NULL,
    Code                    NVARCHAR(50)    NOT NULL,
    Name                    NVARCHAR(200)   NOT NULL,
    IsApproved              BIT             NOT NULL CONSTRAINT DF_Brands_IsApproved DEFAULT 0,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Brands_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Brands_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Brands PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_Brands_Generics FOREIGN KEY (GenericId) REFERENCES product.Generics(Id),
    CONSTRAINT FK_Brands_Manufacturers FOREIGN KEY (ManufacturerId) REFERENCES product.Manufacturers(Id),
    CONSTRAINT UQ_Brands_Manufacturer_Name UNIQUE (ManufacturerId, Name)
);

CREATE INDEX IX_Brands_Generic ON product.Brands(GenericId) WHERE IsDeleted = 0;
CREATE INDEX IX_Brands_Manufacturer ON product.Brands(ManufacturerId) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- Units Table
-- ----------------------------------------------------------------------------
CREATE TABLE product.Units (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    Code                    NVARCHAR(20)    NOT NULL,
    Name                    NVARCHAR(100)   NOT NULL,
    Description             NVARCHAR(200)   NULL,
    UnitType                NVARCHAR(20)    NOT NULL,  -- Base, Derived
    BaseUnitId              BIGINT          NULL,
    ConversionFactor        DECIMAL(18,6)   NULL,
    IsActive                BIT             NOT NULL CONSTRAINT DF_Units_IsActive DEFAULT 1,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Units_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Units_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Units PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_Units_BaseUnit FOREIGN KEY (BaseUnitId) REFERENCES product.Units(Id),
    CONSTRAINT UQ_Units_Code UNIQUE (Code),
    CONSTRAINT CK_Units_Type_Valid CHECK (UnitType IN ('Base', 'Derived')),
    CONSTRAINT CK_Units_Conversion_Positive CHECK (ConversionFactor IS NULL OR ConversionFactor > 0)
);

-- ----------------------------------------------------------------------------
-- Products Table
-- ----------------------------------------------------------------------------
CREATE TABLE product.Products (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    CompanyId               BIGINT          NOT NULL,
    SKU                     NVARCHAR(100)   NOT NULL,
    Name                    NVARCHAR(300)   NOT NULL,
    GenericName             NVARCHAR(200)   NULL,
    BrandName               NVARCHAR(200)   NULL,
    Description             NVARCHAR(1000)  NULL,
    ManufacturerId          BIGINT          NULL,
    CategoryId              BIGINT          NOT NULL,
    GenericId               BIGINT          NULL,
    BrandId                 BIGINT          NULL,
    TherapeuticClass        NVARCHAR(200)   NULL,
    ATCCode                 NVARCHAR(50)    NULL,
    DosageForm              NVARCHAR(100)   NULL,
    Strength                NVARCHAR(100)   NULL,
    UnitOfMeasureId         BIGINT          NULL,
    StorageConditions       NVARCHAR(500)   NULL,
    RequiresRefrigeration   BIT             NOT NULL CONSTRAINT DF_Products_RequiresRefrigeration DEFAULT 0,
    IsControlledSubstance   BIT             NOT NULL CONSTRAINT DF_Products_IsControlledSubstance DEFAULT 0,
    ControlledSubstanceSchedule NVARCHAR(20) NULL,
    PrescriptionRequired    BIT             NOT NULL CONSTRAINT DF_Products_PrescriptionRequired DEFAULT 0,
    Status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_Products_Status DEFAULT 'Active',
    TaxCategoryId           BIGINT          NULL,
    ReorderLevel            INT             NOT NULL CONSTRAINT DF_Products_ReorderLevel DEFAULT 0,
    MaxStockLevel           INT             NOT NULL CONSTRAINT DF_Products_MaxStockLevel DEFAULT 0,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_Products_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_Products_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_Products PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_Products_Companies FOREIGN KEY (CompanyId) REFERENCES core.Companies(Id),
    CONSTRAINT FK_Products_Manufacturers FOREIGN KEY (ManufacturerId) REFERENCES product.Manufacturers(Id),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) REFERENCES product.Categories(Id),
    CONSTRAINT FK_Products_Generics FOREIGN KEY (GenericId) REFERENCES product.Generics(Id),
    CONSTRAINT FK_Products_Brands FOREIGN KEY (BrandId) REFERENCES product.Brands(Id),
    CONSTRAINT FK_Products_Units FOREIGN KEY (UnitOfMeasureId) REFERENCES product.Units(Id),
    CONSTRAINT UQ_Products_Company_SKU UNIQUE (CompanyId, SKU),
    CONSTRAINT CK_Products_Status_Valid CHECK (Status IN ('Active', 'Discontinued', 'Recalled', 'Pending')),
    CONSTRAINT CK_Products_StockLevels_Valid CHECK (ReorderLevel <= MaxStockLevel OR MaxStockLevel = 0)
);

CREATE INDEX IX_Products_Company ON product.Products(CompanyId) WHERE IsDeleted = 0;
CREATE INDEX IX_Products_Category ON product.Products(CategoryId) WHERE IsDeleted = 0;
CREATE INDEX IX_Products_Status ON product.Products(Status) WHERE IsDeleted = 0;
CREATE INDEX IX_Products_Manufacturer ON product.Products(ManufacturerId) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- ProductVariants Table
-- ----------------------------------------------------------------------------
CREATE TABLE product.ProductVariants (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    ProductId               BIGINT          NOT NULL,
    VariantType             NVARCHAR(50)    NOT NULL,
    VariantValue            NVARCHAR(100)   NOT NULL,
    SKU                     NVARCHAR(100)   NULL,
    Barcode                 NVARCHAR(100)   NULL,
    Price                   DECIMAL(18,4)   NOT NULL CONSTRAINT DF_ProductVariants_Price DEFAULT 0,
    CostPrice               DECIMAL(18,4)   NOT NULL CONSTRAINT DF_ProductVariants_CostPrice DEFAULT 0,
    ReorderLevel            INT             NOT NULL CONSTRAINT DF_ProductVariants_ReorderLevel DEFAULT 0,
    MaxStockLevel           INT             NOT NULL CONSTRAINT DF_ProductVariants_MaxStockLevel DEFAULT 0,
    Status                  NVARCHAR(20)    NOT NULL CONSTRAINT DF_ProductVariants_Status DEFAULT 'Active',
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_ProductVariants_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_ProductVariants_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_ProductVariants PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_ProductVariants_Products FOREIGN KEY (ProductId) REFERENCES product.Products(Id),
    CONSTRAINT UQ_ProductVariants_Product_Variant UNIQUE (ProductId, VariantType, VariantValue),
    CONSTRAINT UQ_ProductVariants_SKU UNIQUE (SKU),
    CONSTRAINT UQ_ProductVariants_Barcode UNIQUE (Barcode),
    CONSTRAINT CK_ProductVariants_Price_Positive CHECK (Price >= 0),
    CONSTRAINT CK_ProductVariants_CostPrice_Positive CHECK (CostPrice >= 0),
    CONSTRAINT CK_ProductVariants_Status_Valid CHECK (Status IN ('Active', 'Inactive'))
);

CREATE INDEX IX_ProductVariants_Product ON product.ProductVariants(ProductId) WHERE IsDeleted = 0;

-- ----------------------------------------------------------------------------
-- ProductBarcodes Table
-- ----------------------------------------------------------------------------
CREATE TABLE product.ProductBarcodes (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    ProductId               BIGINT          NOT NULL,
    ProductVariantId        BIGINT          NULL,
    Barcode                 NVARCHAR(100)   NOT NULL,
    BarcodeType             NVARCHAR(50)    NOT NULL,  -- EAN13, UPC-A, Code128, DataMatrix, QR
    IsPrimary               BIT             NOT NULL CONSTRAINT DF_ProductBarcodes_IsPrimary DEFAULT 0,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_ProductBarcodes_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_ProductBarcodes_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_ProductBarcodes PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_ProductBarcodes_Products FOREIGN KEY (ProductId) REFERENCES product.Products(Id),
    CONSTRAINT FK_ProductBarcodes_ProductVariants FOREIGN KEY (ProductVariantId) REFERENCES product.ProductVariants(Id),
    CONSTRAINT UQ_ProductBarcodes_Code UNIQUE (Barcode),
    CONSTRAINT CK_ProductBarcodes_Type_Valid CHECK (BarcodeType IN ('EAN13', 'UPC-A', 'UPC-E', 'Code128', 'Code39', 'DataMatrix', 'QR'))
);

CREATE INDEX IX_ProductBarcodes_Product ON product.ProductBarcodes(ProductId) WHERE IsDeleted = 0;
CREATE INDEX IX_ProductBarcodes_Primary ON product.ProductBarcodes(ProductId, IsPrimary) WHERE IsDeleted = 0 AND IsPrimary = 1;

-- ----------------------------------------------------------------------------
-- ProductTaxes Table (Many-to-Many between Products and Tax Rates)
-- ----------------------------------------------------------------------------
CREATE TABLE product.ProductTaxes (
    Id                      BIGINT          IDENTITY(1,1) NOT NULL,
    ProductId               BIGINT          NOT NULL,
    TaxCategoryId           BIGINT          NOT NULL,
    EffectiveDate           DATETIME2(0)    NOT NULL,
    ExpiryDate              DATETIME2(0)    NULL,
    TaxRate                 DECIMAL(5,2)    NOT NULL,
    IsCompound              BIT             NOT NULL CONSTRAINT DF_ProductTaxes_IsCompound DEFAULT 0,
    
    -- Audit columns
    CreatedBy               INT             NOT NULL,
    CreatedDate             DATETIME2(0)    NOT NULL CONSTRAINT DF_ProductTaxes_CreatedDate DEFAULT SYSUTCDATETIME(),
    ModifiedBy              INT             NULL,
    ModifiedDate            DATETIME2(0)    NULL,
    IsDeleted               BIT             NOT NULL CONSTRAINT DF_ProductTaxes_IsDeleted DEFAULT 0,
    DeletedBy               INT             NULL,
    DeletedDate             DATETIME2(0)    NULL,
    RowVersion              ROWVERSION      NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_ProductTaxes PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_ProductTaxes_Products FOREIGN KEY (ProductId) REFERENCES product.Products(Id),
    CONSTRAINT FK_ProductTaxes_TaxCategories FOREIGN KEY (TaxCategoryId) REFERENCES finance.TaxRates(Id),
    CONSTRAINT CK_ProductTaxes_Rate_Valid CHECK (TaxRate BETWEEN 0 AND 100),
    CONSTRAINT CK_ProductTaxes_Dates_Valid CHECK (ExpiryDate IS NULL OR ExpiryDate > EffectiveDate)
);

CREATE INDEX IX_ProductTaxes_Product ON product.ProductTaxes(ProductId) WHERE IsDeleted = 0;
CREATE INDEX IX_ProductTaxes_Effective ON product.ProductTaxes(ProductId, EffectiveDate) WHERE IsDeleted = 0;
