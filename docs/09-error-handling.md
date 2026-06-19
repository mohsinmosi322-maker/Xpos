# Error Handling Strategy

**Version:** 1.0  
**Document ID:** ERR-001  
**Created:** WO-0002  
**Related:** [Coding Standards](./08-coding-standards.md), [Logging Strategy](./10-logging-strategy.md)

---

## 1. Introduction

This document defines the error handling strategy for PharmaX Enterprise. Consistent error handling ensures:

- Predictable application behavior
- Clear communication with users
- Effective debugging and troubleshooting
- Security through controlled information disclosure
- Audit trail for failures

---

## 2. Exception Hierarchy

### 2.1 Base Exception Classes

```
System.Exception
├── PharmaXException (Abstract base for all custom exceptions)
│   ├── BusinessException
│   │   ├── ValidationException
│   │   ├── AuthorizationException
│   │   ├── NotFoundException
│   │   ├── ConcurrencyException
│   │   └── InvalidStateException
│   ├── InfrastructureException
│   │   ├── DatabaseException
│   │   │   ├── ConnectionException
│   │   │   ├── QueryException
│   │   │   └── ConstraintViolationException
│   │   ├── ExternalServiceException
│   │   └── FileSystemException
│   └── TechnicalException
        ├── ConfigurationException
        └── SerializationException
```

### 2.2 Base Exception Implementation

```csharp
public abstract class PharmaXException : Exception
{
    public string ErrorCode { get; }
    public DateTime Timestamp { get; }
    public string? CorrelationId { get; }
    
    protected PharmaXException(
        string message, 
        string errorCode,
        Exception? innerException = null)
        : base(message, innerException)
    {
        ErrorCode = errorCode;
        Timestamp = DateTime.UtcNow;
        CorrelationId = Guid.NewGuid().ToString("N")[..8];
    }
}
```

---

## 3. Business Exceptions

### 3.1 BusinessException

Base class for business rule violations.

```csharp
public class BusinessException : PharmaXException
{
    public string? EntityName { get; }
    public object? EntityId { get; }
    
    public BusinessException(
        string message,
        string? entityName = null,
        object? entityId = null)
        : base(message, "BUSINESS_ERROR")
    {
        EntityName = entityName;
        EntityId = entityId;
    }
}
```

**Usage Examples**:
- Company name already exists
- Insufficient inventory for sale
- Cannot delete company with active branches
- Order total exceeds credit limit

### 3.2 ValidationException

Input validation failures.

```csharp
public class ValidationException : BusinessException
{
    public IDictionary<string, string[]> Errors { get; }
    
    public ValidationException(string message)
        : base(message)
    {
        Errors = new Dictionary<string, string[]>();
    }
    
    public ValidationException(IDictionary<string, string[]> errors)
        : base("Validation failed")
    {
        Errors = errors;
    }
    
    public void AddError(string property, string error)
    {
        if (!Errors.ContainsKey(property))
            Errors[property] = Array.Empty<string>();
        
        Errors[property] = Errors[property].Append(error).ToArray();
    }
}
```

**Usage Examples**:
- Required field missing
- Invalid email format
- Date range invalid
- Numeric value out of range

### 3.3 AuthorizationException

Permission or access denied.

```csharp
public class AuthorizationException : BusinessException
{
    public string? RequiredPermission { get; }
    public string? Resource { get; }
    
    public AuthorizationException(
        string message,
        string? requiredPermission = null,
        string? resource = null)
        : base(message)
    {
        RequiredPermission = requiredPermission;
        Resource = resource;
    }
}
```

**Usage Examples**:
- User lacks permission to view companies
- Access denied to another user's data
- Session expired
- Account locked

### 3.4 NotFoundException

Requested resource not found.

```csharp
public class NotFoundException : BusinessException
{
    public string? EntityName { get; }
    public object? Key { get; }
    
    public NotFoundException(string entityName, object key)
        : base($"{entityName} with key '{key}' not found")
    {
        EntityName = entityName;
        Key = key;
    }
}
```

**Usage Examples**:
- Company not found
- User not found
- Product not found
- Order not found

### 3.5 ConcurrencyException

Optimistic concurrency violation.

```csharp
public class ConcurrencyException : BusinessException
{
    public string? EntityName { get; }
    public object? EntityId { get; }
    
    public ConcurrencyException(string entityName, object entityId)
        : base($"The {entityName} was modified by another user")
    {
        EntityName = entityName;
        EntityId = entityId;
    }
}
```

### 3.6 InvalidStateException

Operation not valid in current state.

```csharp
public class InvalidStateException : BusinessException
{
    public string? CurrentState { get; }
    public string? RequiredState { get; }
    
    public InvalidStateException(
        string message,
        string? currentState = null,
        string? requiredState = null)
        : base(message)
    {
        CurrentState = currentState;
        RequiredState = requiredState;
    }
}
```

**Usage Examples**:
- Cannot ship order that is not confirmed
- Cannot cancel delivered order
- Cannot modify processed transaction

---

## 4. Infrastructure Exceptions

### 4.1 InfrastructureException

Base class for technical/infrastructure failures.

```csharp
public class InfrastructureException : PharmaXException
{
    public InfrastructureException(string message, Exception? innerException = null)
        : base(message, "INFRASTRUCTURE_ERROR", innerException)
    {
    }
}
```

### 4.2 DatabaseException

Database operation failures.

```csharp
public class DatabaseException : InfrastructureException
{
    public string? Operation { get; }
    public int? ErrorCode { get; }
    
    public DatabaseException(
        string message,
        string? operation = null,
        int? errorCode = null,
        Exception? innerException = null)
        : base(message, innerException)
    {
        Operation = operation;
        ErrorCode = errorCode;
    }
}
```

**Subtypes**:
- `ConnectionException`: Database connection failures
- `QueryException`: SQL query execution failures
- `ConstraintViolationException`: Primary/foreign key, unique constraint violations

### 4.3 ExternalServiceException

Third-party service failures.

```csharp
public class ExternalServiceException : InfrastructureException
{
    public string? ServiceName { get; }
    public int? HttpStatusCode { get; }
    
    public ExternalServiceException(
        string message,
        string? serviceName = null,
        int? httpStatusCode = null,
        Exception? innerException = null)
        : base(message, innerException)
    {
        ServiceName = serviceName;
        HttpStatusCode = httpStatusCode;
    }
}
```

### 4.4 FileSystemException

File operation failures.

```csharp
public class FileSystemException : InfrastructureException
{
    public string? FilePath { get; }
    public string? Operation { get; }
    
    public FileSystemException(
        string message,
        string? filePath = null,
        string? operation = null,
        Exception? innerException = null)
        : base(message, innerException)
    {
        FilePath = filePath;
        Operation = operation;
    }
}
```

---

## 5. Technical Exceptions

### 5.1 ConfigurationException

Configuration-related errors.

```csharp
public class ConfigurationException : PharmaXException
{
    public string? ConfigurationKey { get; }
    
    public ConfigurationException(
        string message,
        string? configurationKey = null)
        : base(message, "CONFIGURATION_ERROR")
    {
        ConfigurationKey = configurationKey;
    }
}
```

### 5.2 SerializationException

Data serialization failures.

```csharp
public class SerializationException : PharmaXException
{
    public string? DataType { get; }
    
    public SerializationException(
        string message,
        string? dataType = null)
        : base(message, "SERIALIZATION_ERROR")
    {
        DataType = dataType;
    }
}
```

---

## 6. UI Error Handling

### 6.1 Error Display Principles

1. **User-Friendly Messages**: Never show raw exception messages to users
2. **Actionable Information**: Tell users what they can do
3. **Consistent Format**: Use standard error dialog format
4. **Error Codes**: Include reference codes for support
5. **No Technical Details**: Hide stack traces and internal details

### 6.2 Error Message Mapping

```csharp
public static class ErrorMessageMapper
{
    public static string GetUserMessage(Exception ex)
    {
        return ex switch
        {
            ValidationException ve => FormatValidationErrors(ve),
            AuthorizationException ae => "You don't have permission to perform this action.",
            NotFoundException nfe => "The requested item was not found.",
            ConcurrencyException ce => "The data was modified by another user. Please refresh and try again.",
            DatabaseException dbe when (dbe.ErrorCode == 2627) => "A record with this information already exists.",
            DatabaseException dbe when (dbe.ErrorCode == 547) => "This record cannot be deleted because it is referenced by other data.",
            BusinessException be => be.Message,
            InfrastructureException ie => "A system error occurred. Please contact support.",
            _ => "An unexpected error occurred. Please try again."
        };
    }
    
    private static string FormatValidationErrors(ValidationException ve)
    {
        var errors = ve.Errors.SelectMany(kvp => kvp.Value.Select(v => $"{kvp.Key}: {v}"));
        return string.Join("\n", errors);
    }
}
```

### 6.3 Error Dialog Standard

```
┌─────────────────────────────────────────┐
│  ⚠ Error                               │
├─────────────────────────────────────────┤
│                                         │
│  The requested company could not be     │
│  found. It may have been deleted by     │
│  another user.                          │
│                                         │
│  Error Code: ERR-20240101-ABC123        │
│                                         │
│         [  OK  ]  [  Help  ]            │
│                                         │
└─────────────────────────────────────────┘
```

### 6.4 Form-Level Error Handling

```csharp
public partial class CompanyForm : Form
{
    private readonly ICompanyService _companyService;
    private readonly ILogger<CompanyForm> _logger;
    
    public CompanyForm(ICompanyService companyService, ILogger<CompanyForm> logger)
    {
        _companyService = companyService;
        _logger = logger;
    }
    
    private async Task LoadCompanyAsync(int companyId)
    {
        try
        {
            var company = await _companyService.GetByIdAsync(companyId);
            BindCompany(company);
        }
        catch (NotFoundException)
        {
            ShowError("Company not found", "The company you're looking for doesn't exist.");
            Close();
        }
        catch (AuthorizationException)
        {
            ShowError("Access Denied", "You don't have permission to view this company.");
            Close();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error loading company {CompanyId}", companyId);
            ShowError("Error", "Failed to load company. Please try again.");
        }
    }
    
    private void ShowError(string title, string message)
    {
        MessageBox.Show(this, message, title, MessageBoxButtons.OK, MessageBoxIcon.Error);
    }
}
```

---

## 7. Logging Strategy

### 7.1 Exception Logging Levels

| Exception Type | Log Level | Include Stack Trace |
|---------------|-----------|---------------------|
| ValidationException | Warning | No |
| AuthorizationException | Warning | No |
| NotFoundException | Information | No |
| BusinessException | Warning | Yes |
| InfrastructureException | Error | Yes |
| TechnicalException | Error | Yes |
| Unhandled Exception | Critical | Yes |

### 7.2 Logging Format

```csharp
_logger.LogError(ex, """
    Error occurred during {Operation}
    User: {UserId}
    Entity: {EntityName}
    Error Code: {ErrorCode}
    Correlation Id: {CorrelationId}
    """, operation, userId, entityName, errorCode, correlationId);
```

### 7.3 Sensitive Data Exclusion

Never log:
- Passwords
- Connection strings
- Personal identification numbers
- Credit card numbers
- Full authentication tokens

---

## 8. Recovery Guidelines

### 8.1 Retry Strategies

```csharp
public class RetryPolicy
{
    private readonly int _maxRetries;
    private readonly TimeSpan _delay;
    
    public async Task<T> ExecuteAsync<T>(Func<Task<T>> operation)
    {
        var retries = 0;
        while (true)
        {
            try
            {
                return await operation();
            }
            catch (TransientException ex) when (retries < _maxRetries)
            {
                retries++;
                _logger.LogWarning(ex, "Retry {Retry}/{MaxRetries}", retries, _maxRetries);
                await Task.Delay(_delay * retries);
            }
        }
    }
}
```

### 8.2 Transient vs Permanent Errors

**Transient (Retry)**:
- Network timeouts
- Database deadlocks
- Temporary service unavailability
- Connection pool exhaustion

**Permanent (Don't Retry)**:
- Validation errors
- Authorization failures
- Not found errors
- Constraint violations

### 8.3 Compensation Actions

For operations that partially complete:

```csharp
public async Task ProcessOrderAsync(Order order)
{
    var compensationActions = new Stack<Func<Task>>();
    
    try
    {
        await _inventory.ReserveAsync(order.Items);
        compensationActions.Push(async () => await _inventory.ReleaseAsync(order.Items));
        
        await _payment.ChargeAsync(order.Payment);
        compensationActions.Push(async () => await _payment.RefundAsync(order.Payment));
        
        await _orderRepository.CreateAsync(order);
        
        // Success - clear compensation
        compensationActions.Clear();
    }
    catch
    {
        // Execute compensation in reverse order
        while (compensationActions.Count > 0)
        {
            var compensate = compensationActions.Pop();
            await compensate();
        }
        throw;
    }
}
```

---

## 9. Global Exception Handling

### 9.1 Application-Level Handler

```csharp
public class GlobalExceptionHandler
{
    private readonly ILogger<GlobalExceptionHandler> _logger;
    
    public void HandleException(Exception ex)
    {
        // Log the exception
        _logger.LogCritical(ex, "Unhandled exception");
        
        // Track for support
        var errorId = ErrorTracker.Track(ex);
        
        // Show user-friendly message
        ShowGenericError(errorId);
    }
    
    private void ShowGenericError(string errorId)
    {
        MessageBox.Show(
            $"An unexpected error occurred.\n\n" +
            $"Please contact support and reference error ID: {errorId}",
            "System Error",
            MessageBoxButtons.OK,
            MessageBoxIcon.Error);
    }
}
```

### 9.2 WinForms Unhandled Exception

```csharp
Application.ThreadException += (sender, e) =>
{
    var handler = serviceProvider.GetRequiredService<GlobalExceptionHandler>();
    handler.HandleException(e.Exception);
};

AppDomain.CurrentDomain.UnhandledException += (sender, e) =>
{
    var handler = serviceProvider.GetRequiredService<GlobalExceptionHandler>();
    handler.HandleException((Exception)e.ExceptionObject);
};
```

---

## 10. Error Codes

### 10.1 Error Code Format

```
ERR-{YYYYMMDD}-{XXXXX}
```

- `ERR`: Error prefix
- `YYYYMMDD`: Date code
- `XXXXX`: Sequential number or hash

### 10.2 Error Code Registry

| Code Pattern | Category | Description |
|-------------|----------|-------------|
| VAL-xxxx | Validation | Input validation errors |
| AUTH-xxxx | Authorization | Permission/access errors |
| NOTF-xxxx | Not Found | Resource not found |
| BUS-xxxx | Business | Business rule violations |
| DB-xxxx | Database | Database errors |
| NET-xxxx | Network | Network/connectivity errors |
| SYS-xxxx | System | System/internal errors |

---

## 11. Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0002 | Architecture Team | Initial definition |

---

*This document is part of the PharmaX Enterprise architectural documentation suite.*
