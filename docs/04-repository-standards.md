# Repository Standards

## PharmaX Enterprise Platform

**Version:** 1.0  
**Document ID:** STD-001  
**Created:** WO-0001  

---

## Overview

This document defines the coding standards, folder structure, naming conventions, and layer responsibilities for the PharmaX Enterprise platform. All development must adhere to these standards to ensure consistency, maintainability, and scalability.

---

## 1. Folder Structure

### 1.1 Solution Structure

```
PharmaX.Enterprise/
│
├── src/
│   ├── PharmaX.Domain/
│   │   ├── Entities/
│   │   │   ├── Common/
│   │   │   ├── Security/
│   │   │   ├── Products/
│   │   │   ├── Inventory/
│   │   │   ├── Sales/
│   │   │   └── Purchasing/
│   │   ├── ValueObjects/
│   │   ├── Enums/
│   │   ├── Events/
│   │   ├── Exceptions/
│   │   ├── Specifications/
│   │   └── PharmaX.Domain.csproj
│   │
│   ├── PharmaX.Application/
│   │   ├── Services/
│   │   │   ├── Interfaces/
│   │   │   └── Implementations/
│   │   ├── DTOs/
│   │   │   ├── Requests/
│   │   │   └── Responses/
│   │   ├── Interfaces/
│   │   │   └── Repositories/
│   │   ├── Mappings/
│   │   ├── Validators/
│   │   ├── Behaviors/
│   │   └── PharmaX.Application.csproj
│   │
│   ├── PharmaX.Infrastructure/
│   │   ├── Data/
│   │   │   ├── Configurations/
│   │   │   └── Migrations/
│   │   ├── Repositories/
│   │   ├── Services/
│   │   │   ├── Email/
│   │   │   ├── FileStorage/
│   │   │   └── External/
│   │   ├── Caching/
│   │   └── PharmaX.Infrastructure.csproj
│   │
│   └── PharmaX.Presentation/
│       ├── Forms/
│       ├── Controls/
│       ├── Dialogs/
│       ├── ViewModels/
│       ├── Converters/
│       ├── Helpers/
│       ├── Resources/
│       │   ├── Images/
│       │   ├── Icons/
│       │   └── Strings/
│       └── PharmaX.Presentation.csproj
│
├── tests/
│   ├── PharmaX.Domain.Tests/
│   ├── PharmaX.Application.Tests/
│   ├── PharmaX.Infrastructure.Tests/
│   └── PharmaX.Presentation.Tests/
│
├── docs/
│   ├── architecture/
│   ├── modules/
│   ├── standards/
│   └── processes/
│
├── build/
├── scripts/
├── .gitignore
├── README.md
└── PharmaX.Enterprise.sln
```

### 1.2 Project Organization Rules

1. **One project per layer**: Each architectural layer has its own project.
2. **Feature folders within layers**: Group related classes by feature, not by type.
3. **Common entities in shared location**: Base classes and common types in `Entities/Common`.
4. **Module separation**: Domain entities organized by business module.

---

## 2. Naming Conventions

### 2.1 General Naming

| Item | Convention | Example |
|------|------------|---------|
| Namespaces | PascalCase | `PharmaX.Domain.Entities` |
| Classes | PascalCase | `SalesOrder`, `UserService` |
| Interfaces | PascalCase with I prefix | `IRepository<T>`, `IUserService` |
| Methods | PascalCase | `GetByIdAsync`, `CreateOrder` |
| Properties | PascalCase | `CustomerId`, `OrderDate` |
| Fields | camelCase with underscore prefix | `_userRepository`, `_logger` |
| Parameters | camelCase | `customerId`, `orderData` |
| Local variables | camelCase | `orderTotal`, `isValid` |
| Constants | PascalCase or UPPER_SNAKE_CASE | `MaxRetryCount`, `DEFAULT_TIMEOUT` |
| Private constants | camelCase with underscore prefix | `_maxRetryCount` |

### 2.2 Entity Naming

| Type | Convention | Example |
|------|------------|---------|
| Aggregate Root | Singular noun | `Company`, `SalesOrder` |
| Entity | Singular noun | `Product`, `Customer` |
| Value Object | Noun phrase | `Money`, `Address`, `AuditInfo` |
| Association Entity | Combined names | `UserRole`, `RolePermission` |
| Enum | Singular PascalCase | `OrderStatus`, `UserType` |

### 2.3 Service Naming

| Type | Convention | Example |
|------|------------|---------|
| Application Service | [Domain]Service | `UserService`, `OrderService` |
| Domain Service | [Domain]DomainService | `PricingDomainService` |
| Infrastructure Service | [Technology]Service | `EmailService`, `CacheService` |
| Repository Interface | IRepository<[Entity]> | `IRepository<User>` |
| Repository Class | Repository<[Entity]> | `Repository<User>` |

### 2.4 DTO Naming

| Type | Convention | Example |
|------|------------|---------|
| Request DTO | [Action][Entity]Request | `CreateUserRequest`, `UpdateOrderRequest` |
| Response DTO | [Entity]Response | `UserResponse`, `OrderDetailResponse` |
| List Response | [Entity]ListResponse | `UserListResponse` |
| Command | [Action][Entity]Command | `CreateUserCommand` |
| Query | Get[Entity]Query | `GetUserByIdQuery` |

### 2.5 File Naming

| Content | Convention | Example |
|---------|------------|---------|
| Entity class | [EntityName].cs | `User.cs`, `SalesOrder.cs` |
| Service interface | I[ServiceName].cs | `IUserService.cs` |
| Service implementation | [ServiceName].cs | `UserService.cs` |
| Repository | [Entity]Repository.cs | `UserRepository.cs` |
| DTO | [DTOName].cs | `UserDto.cs`, `CreateUserRequest.cs` |
| Validator | [Entity]Validator.cs | `UserValidator.cs` |
| Form (WinForms) | [FormName].cs + .Designer.cs | `LoginForm.cs` |
| User Control | [ControlName].cs + .Designer.cs | `ProductSearchControl.cs` |

### 2.6 Database Naming (for reference)

| Object | Convention | Example |
|--------|------------|---------|
| Table | PascalCase or snake_case | `Users`, `sales_orders` |
| Column | camelCase or snake_case | `userId`, `order_date` |
| Primary Key | `PK_[TableName]` | `PK_Users` |
| Foreign Key | `FK_[TableName]_[ReferencedTable]` | `FK_Orders_Customers` |
| Index | `IX_[TableName]_[ColumnName]` | `IX_Users_Email` |
| Unique Constraint | `UQ_[TableName]_[ColumnName]` | `UQ_Users_Username` |

---

## 3. Layer Responsibilities

### 3.1 Domain Layer

**Allowed**:
- Entity definitions
- Business logic methods on entities
- Domain events
- Value objects
- Enumeration types
- Domain exceptions
- Specification pattern implementations
- Repository interfaces (if defined here per architecture choice)

**Not Allowed**:
- Dependencies on external libraries (except .NET base)
- Database access code
- UI-related code
- Application service code
- Infrastructure concerns

**Example**:
```csharp
// ✓ Correct: Domain entity with business logic
public class SalesOrder
{
    public int Id { get; private set; }
    public string OrderNumber { get; private set; }
    public decimal TotalAmount { get; private set; }
    public OrderStatus Status { get; private set; }
    
    private readonly List<SalesOrderLine> _lines = new();
    public IReadOnlyCollection<SalesOrderLine> Lines => _lines.AsReadOnly();
    
    public void Complete()
    {
        if (Status != OrderStatus.Draft)
            throw new DomainException("Only draft orders can be completed.");
        
        Status = OrderStatus.Completed;
        AddDomainEvent(new OrderCompletedEvent(this));
    }
    
    public void AddLine(Product product, int quantity, decimal price)
    {
        // Business validation
        if (quantity <= 0)
            throw new DomainException("Quantity must be positive.");
        
        _lines.Add(new SalesOrderLine(product, quantity, price));
        RecalculateTotal();
    }
}
```

### 3.2 Application Layer

**Allowed**:
- Use case implementations
- Application services
- DTOs
- Interface definitions for repositories
- Validators
- Mappers (AutoMapper profiles)
- Command/Query handlers
- Cross-cutting concern orchestration

**Not Allowed**:
- Business logic (belongs in domain)
- Direct database access
- UI-specific code
- Infrastructure implementations

**Example**:
```csharp
// ✓ Correct: Application service orchestrating domain
public class OrderApplicationService : IOrderApplicationService
{
    private readonly IRepository<SalesOrder> _orderRepository;
    private readonly IRepository<Product> _productRepository;
    private readonly IInventoryService _inventoryService;
    
    public async Task<CompleteOrderResponse> CompleteOrderAsync(CompleteOrderRequest request)
    {
        var order = await _orderRepository.GetByIdAsync(request.OrderId);
        if (order == null)
            throw new NotFoundException($"Order {request.OrderId} not found.");
        
        // Check inventory (infrastructure service)
        foreach (var line in order.Lines)
        {
            var available = await _inventoryService.GetAvailableStockAsync(
                order.BranchId, line.ProductId);
            
            if (available < line.Quantity)
                throw new ValidationException(
                    $"Insufficient stock for product {line.Product.Name}");
        }
        
        order.Complete(); // Domain logic
        await _orderRepository.UpdateAsync(order);
        
        return new CompleteOrderResponse 
        { 
            OrderId = order.Id,
            OrderNumber = order.OrderNumber,
            TotalAmount = order.TotalAmount
        };
    }
}
```

### 3.3 Infrastructure Layer

**Allowed**:
- Repository implementations
- Database context (Entity Framework)
- External service integrations
- File system operations
- Email/SMS services
- Caching implementations
- Authentication providers

**Not Allowed**:
- Business logic
- UI code
- Direct references from Presentation layer

**Example**:
```csharp
// ✓ Correct: Repository implementation
public class OrderRepository : Repository<SalesOrder>, IOrderRepository
{
    public OrderRepository(AppDbContext context) : base(context) { }
    
    public async Task<SalesOrder> GetByOrderNumberAsync(string orderNumber)
    {
        return await DbSet
            .Include(o => o.Lines)
            .ThenInclude(l => l.Product)
            .FirstOrDefaultAsync(o => o.OrderNumber == orderNumber);
    }
    
    public async Task<IEnumerable<SalesOrder>> GetByBranchAsync(int branchId, DateTime fromDate)
    {
        return await DbSet
            .Where(o => o.BranchId == branchId && o.OrderDate >= fromDate)
            .OrderByDescending(o => o.OrderDate)
            .ToListAsync();
    }
}
```

### 3.4 Presentation Layer

**Allowed**:
- WinForms forms and controls
- UI logic and event handlers
- View models
- Data converters
- UI validators
- Resource files

**Not Allowed**:
- Business logic
- Direct database access
- Domain model manipulation (use DTOs)

**Example**:
```csharp
// ✓ Correct: Form using application service via dependency injection
public partial class SalesOrderForm : Form
{
    private readonly IOrderApplicationService _orderService;
    
    public SalesOrderForm(IOrderApplicationService orderService)
    {
        _orderService = orderService;
        InitializeComponent();
    }
    
    private async void btnComplete_Click(object sender, EventArgs e)
    {
        try
        {
            var request = new CompleteOrderRequest 
            { 
                OrderId = GetCurrentOrderId() 
            };
            
            var response = await _orderService.CompleteOrderAsync(request);
            
            MessageBox.Show(
                $"Order {response.OrderNumber} completed successfully!",
                "Success",
                MessageBoxButtons.OK,
                MessageBoxIcon.Information);
                
            RefreshGrid();
        }
        catch (ValidationException ex)
        {
            MessageBox.Show(ex.Message, "Validation Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error completing order");
            MessageBox.Show("An error occurred. Please try again.",
                "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
```

---

## 4. Dependency Rules

### 4.1 Allowed Dependencies

```
Presentation → Application → Domain ← Infrastructure
                              ↑
                    (implements interfaces)
```

| From Layer | Can Reference | Cannot Reference |
|------------|---------------|------------------|
| Presentation | Application, Infrastructure (DI only) | Domain (directly) |
| Application | Domain | Infrastructure, Presentation |
| Domain | None (only .NET BCL) | Any other layer |
| Infrastructure | Domain, Application (interfaces) | Presentation |

### 4.2 Dependency Injection

All dependencies must be injected through constructors:

```csharp
// ✓ Correct: Constructor injection
public class UserService : IUserService
{
    private readonly IRepository<User> _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly ILogger<UserService> _logger;
    
    public UserService(
        IRepository<User> userRepository,
        IPasswordHasher passwordHasher,
        ILogger<UserService> logger)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
        _logger = logger;
    }
}

// ✗ Wrong: Service locator or direct instantiation
public class UserService : IUserService
{
    private readonly IRepository<User> _userRepository;
    
    public UserService()
    {
        _userRepository = ServiceLocator.Resolve<IRepository<User>>(); // ✗
    }
}
```

### 4.3 Interface Segregation

Define interfaces close to where they are used:

```csharp
// ✓ Correct: Interface in Application layer, implemented in Infrastructure
// PharmaX.Application/Interfaces/Repositories/IUserRepository.cs
public interface IUserRepository : IRepository<User>
{
    Task<User> GetByUsernameAsync(string username);
    Task<User> GetByEmailAsync(string email);
    Task<bool> UsernameExistsAsync(string username);
}

// PharmaX.Infrastructure/Repositories/UserRepository.cs
public class UserRepository : Repository<User>, IUserRepository
{
    // Implementation
}
```

---

## 5. Coding Standards

### 5.1 C# Language Features

**Required**:
- Use latest stable C# features supported by target framework
- Pattern matching where appropriate
- Nullable reference types enabled
- Async/await for I/O operations
- Expression-bodied members for simple properties/methods

**Recommended**:
- Records for DTOs and value objects
- Init-only properties for immutability
- File-scoped namespaces
- Global usings (sparingly)

### 5.2 Code Style

```csharp
// ✓ Correct: Clean code style
public class ProductService : IProductService
{
    private readonly IRepository<Product> _productRepository;
    private readonly ILogger<ProductService> _logger;
    
    public ProductService(
        IRepository<Product> productRepository,
        ILogger<ProductService> logger)
    {
        _productRepository = productRepository;
        _logger = logger;
    }
    
    public async Task<ProductResponse> GetProductAsync(int id)
    {
        var product = await _productRepository.GetByIdAsync(id);
        
        if (product == null)
        {
            _logger.LogWarning("Product {ProductId} not found", id);
            throw new NotFoundException($"Product with ID {id} not found.");
        }
        
        return product.ToResponse();
    }
    
    public async Task<ProductResponse> CreateProductAsync(CreateProductRequest request)
    {
        var product = new Product(
            request.SKU,
            request.Name,
            request.Price);
        
        await _productRepository.AddAsync(product);
        await _productRepository.SaveChangesAsync();
        
        _logger.LogInformation("Product {ProductId} created", product.Id);
        
        return product.ToResponse();
    }
}
```

### 5.3 Error Handling

```csharp
// ✓ Correct: Specific exception handling
public async Task<OrderResponse> ProcessOrderAsync(int orderId)
{
    try
    {
        var order = await _orderRepository.GetByIdAsync(orderId);
        
        if (order == null)
            throw new NotFoundException($"Order {orderId} not found.");
        
        order.Process();
        await _orderRepository.UpdateAsync(order);
        
        return order.ToResponse();
    }
    catch (DomainException ex)
    {
        _logger.LogWarning(ex, "Domain rule violation for order {OrderId}", orderId);
        throw; // Re-throw domain exceptions
    }
    catch (DbUpdateException ex)
    {
        _logger.LogError(ex, "Database error processing order {OrderId}", orderId);
        throw new DataAccessException("Failed to save order changes.", ex);
    }
}
```

### 5.4 Logging

```csharp
// ✓ Correct: Structured logging
public class OrderService
{
    private readonly ILogger<OrderService> _logger;
    
    public async Task CancelOrderAsync(int orderId, string reason)
    {
        _logger.LogInformation(
            "Cancelling order {OrderId} with reason {Reason}", 
            orderId, reason);
        
        try
        {
            var order = await _orderRepository.GetByIdAsync(orderId);
            order.Cancel(reason);
            await _orderRepository.UpdateAsync(order);
            
            _logger.LogInformation(
                "Order {OrderId} cancelled successfully", orderId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex, 
                "Failed to cancel order {OrderId}", 
                orderId);
            throw;
        }
    }
}
```

### 5.5 Documentation

```csharp
/// <summary>
/// Service for managing sales orders.
/// </summary>
public interface ISalesOrderService
{
    /// <summary>
    /// Retrieves an order by its unique identifier.
    /// </summary>
    /// <param name="orderId">The unique order identifier.</param>
    /// <returns>The order details.</returns>
    /// <exception cref="NotFoundException">Thrown when the order is not found.</exception>
    Task<OrderResponse> GetOrderByIdAsync(int orderId);
    
    /// <summary>
    /// Creates a new sales order.
    /// </summary>
    /// <param name="request">The order creation request.</param>
    /// <returns>The created order details.</returns>
    Task<OrderResponse> CreateOrderAsync(CreateOrderRequest request);
}
```

---

## 6. Testing Standards

### 6.1 Test Project Structure

```
PharmaX.Domain.Tests/
├── Entities/
│   ├── SalesOrderTests.cs
│   └── ProductTests.cs
├── ValueObjects/
│   └── MoneyTests.cs
└── Services/
    └── PricingDomainServiceTests.cs

PharmaX.Application.Tests/
├── Services/
│   └── OrderApplicationServiceTests.cs
└── Validators/
    └── CreateOrderRequestValidatorTests.cs
```

### 6.2 Test Naming

```csharp
// ✓ Correct: Test method naming convention
[TestClass]
public class SalesOrderTests
{
    [TestMethod]
    public void Complete_WhenDraftOrder_ChangesStatusToCompleted()
    {
        // Arrange
        // Act
        // Assert
    }
    
    [TestMethod]
    public void Complete_WhenAlreadyCompleted_ThrowsDomainException()
    {
        // Arrange
        // Act
        // Assert
    }
}
```

### 6.3 Unit Test Guidelines

1. **Arrange-Act-Assert**: Follow AAA pattern
2. **One assertion per concept**: Multiple asserts OK if testing same concept
3. **Test behavior, not implementation**: Focus on what, not how
4. **Use meaningful test data**: Avoid magic numbers
5. **Mock external dependencies**: Isolate unit under test

---

## 7. Version Control Standards

### 7.1 Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Build/config changes

**Example**:
```
feat(auth): add password reset functionality

Implemented password reset flow with email verification.
- Added PasswordResetRequest entity
- Added PasswordResetService
- Added email template for reset notifications

Resolves: WO-0005
```

### 7.2 Code Review Checklist

- [ ] Code follows naming conventions
- [ ] No business logic in Presentation layer
- [ ] Domain layer has no external dependencies
- [ ] Proper error handling implemented
- [ ] Logging added for important operations
- [ ] Tests included for new functionality
- [ ] XML documentation for public APIs
- [ ] No hardcoded values (use configuration)
- [ ] SQL queries use parameterization
- [ ] Async methods use Async suffix

---

## Related Documents

- [Architecture Overview](./01-architecture-overview.md)
- [Module Map](./02-module-map.md)
- [Domain Model](./03-domain-model.md)
- [Git Workflow](./05-git-workflow.md)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0001 | Architecture Team | Initial standards definition |

---

*This document is part of the PharmaX Enterprise architectural documentation suite.*
