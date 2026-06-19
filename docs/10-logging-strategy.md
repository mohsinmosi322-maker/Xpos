# Logging Strategy

**Version:** 1.0  
**Document ID:** LOG-001  
**Created:** WO-0002  
**Related:** [Error Handling](./09-error-handling.md), [Non-Functional Requirements](./07-non-functional-requirements.md)

---

## 1. Introduction

This document defines the logging strategy for PharmaX Enterprise. Effective logging provides:

- Visibility into application behavior
- Debugging and troubleshooting capability
- Security audit trail
- Performance monitoring
- Compliance evidence

---

## 2. Log Levels

### 2.1 Level Definitions

| Level | Description | When to Use | Production Default |
|-------|-------------|-------------|-------------------|
| Trace | Most detailed information | Fine-grained debugging, variable values | Off |
| Debug | Diagnostic information | Method entry/exit, intermediate states | Off |
| Information | Significant events | Business operations, user actions, state changes | On |
| Warning | Potential issues | Recoverable errors, validation failures, retries | On |
| Error | Unexpected failures | Operation failures, exceptions requiring attention | On |
| Critical | System-wide failures | Application crashes, data corruption, security breaches | On |

### 2.2 Level Usage Guidelines

```csharp
// TRACE - Detailed debugging (disabled in production)
_logger.LogTrace("Processing item {ItemId} with quantity {Quantity}", item.Id, item.Quantity);

// DEBUG - Diagnostic information
_logger.LogDebug("Entering method {MethodName} with {ParamCount} parameters", methodName, parameters.Count);

// INFORMATION - Normal business operations
_logger.LogInformation("User {UserId} logged in from {IpAddress}", userId, ipAddress);
_logger.LogInformation("Order {OrderId} created with total {Total}", orderId, total);

// WARNING - Recoverable issues
_logger.LogWarning("Failed to send email notification: {Error}", errorMessage);
_logger.LogWarning("Retry {Attempt}/{MaxAttempts} for operation {Operation}", attempt, maxAttempts, operation);

// ERROR - Unexpected failures
_logger.LogError(ex, "Failed to process payment for order {OrderId}", orderId);

// CRITICAL - System-wide failures
_logger.LogCritical(ex, "Database connection pool exhausted - service unavailable");
```

### 2.3 Production Configuration

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "System": "Warning",
      "PharmaX.Domain": "Information",
      "PharmaX.Application": "Information",
      "PharmaX.Infrastructure": "Warning",
      "PharmaX.WinForms": "Information"
    }
  }
}
```

---

## 3. Log Categories

### 3.1 Category Structure

```
PharmaX
├── Domain
│   ├── Entities
│   ├── Services
│   └── Events
├── Application
│   ├── Services
│   ├── Commands
│   ├── Queries
│   └── Validators
├── Infrastructure
│   ├── Data
│   ├── Repositories
│   └── External
├── WinForms
│   ├── Forms
│   ├── Presenters
│   └── Controls
└── Security
    ├── Authentication
    └── Authorization
```

### 3.2 Category Usage

```csharp
// Logger injection with category
public class CompanyService
{
    private readonly ILogger<CompanyService> _logger;
    
    // Category automatically set to "PharmaX.Application.Services.CompanyService"
    public CompanyService(ILogger<CompanyService> logger)
    {
        _logger = logger;
    }
}

// Custom category when needed
var logger = loggerFactory.CreateLogger("PharmaX.Security.Authentication");
```

---

## 4. Structured Logging

### 4.1 Principles

- Use structured placeholders, not string interpolation
- Include context-rich properties
- Use consistent property names
- Avoid sensitive data in properties

### 4.2 Format Examples

```csharp
// Correct: Structured logging
_logger.LogInformation(
    "Company {CompanyId} created by user {UserId} at {Timestamp}",
    companyId,
    userId,
    DateTime.UtcNow);

// Incorrect: String interpolation (harder to query)
_logger.LogInformation($"Company {companyId} created by user {userId}");
```

### 4.3 Standard Properties

Include these properties where applicable:

| Property | Type | Description |
|----------|------|-------------|
| UserId | string | Authenticated user identifier |
| CorrelationId | string | Request/correlation identifier |
| EntityName | string | Type of entity involved |
| EntityId | int/string | Entity identifier |
| Action | string | Operation performed |
| Duration | long | Operation duration in milliseconds |
| Success | bool | Whether operation succeeded |
| IpAddress | string | Client IP address |
| MachineName | string | Client/workstation name |

### 4.4 Scope Context

```csharp
using (_logger.BeginScope(new Dictionary<string, object>
{
    ["UserId"] = currentUser.Id,
    ["CorrelationId"] = correlationId,
    ["CompanyId"] = companyId
}))
{
    // All logs within this scope include the context
    await _companyService.DoSomethingAsync();
}
```

---

## 5. Sensitive Data Handling

### 5.1 Never Log

The following must NEVER appear in logs:

- Passwords (plain or hashed)
- Connection strings
- API keys and secrets
- Personal identification numbers
- Credit card numbers
- Full authentication tokens
- Session tokens
- Private encryption keys

### 5.2 Masking Strategy

```csharp
// Correct: Masked sensitive data
_logger.LogInformation("User {UserId} authenticated", userId);
_logger.LogInformation("Password reset requested for user {Email}", MaskEmail(user.Email));

private static string MaskEmail(string email)
{
    var parts = email.Split('@');
    return $"{parts[0][0]}***@{parts[1]}";
}

// Correct: Redacted connection info
_logger.LogInformation("Connected to database server {Server}", connectionString.Server);
// Not the full connection string!
```

### 5.3 Audit Log Exceptions

Audit logs may contain:
- User identifiers (required for accountability)
- Timestamps
- Action types
- Entity references (IDs, not full data)

Audit logs must NOT contain:
- Passwords
- Full personal data
- Complete financial data

---

## 6. Log Retention

### 6.1 Retention Policy

| Log Type | Active Storage | Archive | Total Retention |
|----------|---------------|---------|-----------------|
| Application Logs | 30 days | 60 days | 90 days |
| Security Logs | 90 days | 270 days | 1 year |
| Audit Logs | 180 days | 6.5 years | 7 years |
| Performance Logs | 7 days | 23 days | 30 days |
| Debug Logs | 24 hours | None | 24 hours |

### 6.2 Storage Locations

```
/logs/
├── active/
│   ├── application/
│   │   └── app-{YYYY-MM-DD}.log
│   ├── security/
│   │   └── security-{YYYY-MM-DD}.log
│   └── audit/
│       └── audit-{YYYY-MM-DD}.log
├── archive/
│   └── {YYYY}/
│       └── {MM}/
│           └── compressed archives
└── config/
    └── retention-policy.json
```

### 6.3 Rotation Strategy

- Daily log file rotation
- Automatic compression after 7 days
- Automatic archival after 30 days
- Automatic deletion after retention period

---

## 7. Correlation Identifiers

### 7.1 Purpose

Correlation IDs enable tracing requests across:
- Multiple method calls
- Layer boundaries
- Future distributed systems
- Async operations

### 7.2 Implementation

```csharp
public interface ICorrelationContext
{
    string CorrelationId { get; }
    DateTime StartTime { get; }
}

public class CorrelationContext : ICorrelationContext
{
    public string CorrelationId { get; } = Guid.NewGuid().ToString("N")[..16];
    public DateTime StartTime { get; } = DateTime.UtcNow;
}

// Usage in request pipeline
public async Task HandleRequestAsync(Request request)
{
    using (_logger.BeginScope(new Dictionary<string, object>
    {
        ["CorrelationId"] = _correlationContext.CorrelationId
    }))
    {
        _logger.LogInformation("Starting request {RequestType}", request.GetType().Name);
        
        // All nested logs include CorrelationId
        await ProcessAsync(request);
        
        _logger.LogInformation("Completed request in {Duration}ms", 
            (DateTime.UtcNow - _correlationContext.StartTime).TotalMilliseconds);
    }
}
```

### 7.3 Propagation

For future web service integration:
- Include `X-Correlation-ID` header in HTTP requests
- Extract from incoming requests
- Generate new if not provided

---

## 8. Audit Logging vs Application Logging

### 8.1 Differences

| Aspect | Application Logging | Audit Logging |
|--------|--------------------|---------------|
| Purpose | Debugging, monitoring | Compliance, accountability |
| Audience | Developers, support | Auditors, compliance officers |
| Retention | 90 days | 7+ years |
| Immutability | Can be rotated/deleted | Must be immutable |
| Content | Technical details | Who, what, when |
| Volume | High | Selective |

### 8.2 Audit Log Requirements

**Must Record**:
- User identity
- Timestamp (UTC)
- Action performed
- Entity affected
- Before/after values (for updates)
- Result (success/failure)

**Must Not**:
- Be modifiable after write
- Allow deletion
- Contain sensitive data

### 8.3 Audit Event Examples

```csharp
_auditLogger.LogAudit(new AuditEvent
{
    EventType = "USER_LOGIN",
    UserId = user.Id,
    UserName = user.Username,
    Timestamp = DateTime.UtcNow,
    Success = true,
    IpAddress = clientIp,
    MachineName = Environment.MachineName,
    Details = new { LoginMethod = "password" }
});

_auditLogger.LogAudit(new AuditEvent
{
    EventType = "DATA_MODIFIED",
    UserId = currentUser.Id,
    Timestamp = DateTime.UtcNow,
    EntityName = "Company",
    EntityId = company.Id,
    Success = true,
    OldValues = originalValues,
    NewValues = modifiedValues
});
```

### 8.4 Audit Storage

- Separate database table from application logs
- Write-only access (no updates/deletes)
- Hash chain for tamper detection
- Regular integrity verification

---

## 9. Performance Logging

### 9.1 Metrics to Capture

| Metric | Description | Threshold |
|--------|-------------|-----------|
| Request Duration | Total request time | > 2 seconds |
| Query Duration | Database query time | > 500ms |
| Method Duration | Critical method execution | > 100ms |
| Memory Usage | Heap memory at checkpoints | > 256MB |
| Connection Count | Active DB connections | > 80% pool |

### 9.2 Performance Log Format

```csharp
_logger.LogInformation(
    "PERF: {Operation} completed in {Duration}ms with {RecordCount} records",
    operation,
    stopwatch.ElapsedMilliseconds,
    recordCount);
```

### 9.3 Slow Query Logging

```csharp
public class SlowQueryLogger
{
    private const int SlowQueryThreshold = 500; // ms
    
    public void LogQuery(string sql, int durationMs, int rowCount)
    {
        if (durationMs > SlowQueryThreshold)
        {
            _logger.LogWarning(
                "SLOW QUERY: {Duration}ms, {RowCount} rows\n{Sql}",
                durationMs,
                rowCount,
                TruncateSql(sql, 1000));
        }
    }
}
```

---

## 10. Implementation Guidelines

### 10.1 Logger Injection

```csharp
// Preferred: Generic ILogger<T>
public class CompanyService
{
    private readonly ILogger<CompanyService> _logger;
    
    public CompanyService(ILogger<CompanyService> logger)
    {
        _logger = logger;
    }
}
```

### 10.2 Message Templates

- Use named placeholders
- Keep messages concise but descriptive
- Include action and result
- Use consistent terminology

```csharp
// Good templates
"Company {CompanyId} created successfully"
"Failed to load product {ProductId}: {Error}"
"User {UserId} permission check for {Permission} returned {Result}"

// Poor templates
"Error occurred"  // Too vague
"Company created"  // Missing identifier
"Process finished"  // What process?
```

### 10.3 Exception Logging

```csharp
// Always pass exception as first parameter after level
try
{
    await _repository.AddAsync(company);
}
catch (DbException ex)
{
    _logger.LogError(ex, "Database error adding company {CompanyId}", company.Id);
    throw;
}

// Include exception details in message only when necessary
_logger.LogError("Operation failed: {Error}", ex.Message);  // Less preferred
```

---

## 11. Log Aggregation (Future)

### 11.1 Centralized Logging Architecture

For multi-branch deployments:

```
┌─────────────┐     ┌─────────────┐
│  Branch 1   │     │  Branch 2   │
│  App Logs   │     │  App Logs   │
└──────┬──────┘     └──────┬──────┘
       │                   │
       ▼                   ▼
┌─────────────────────────────────┐
│      Log Collector/Forwarder    │
└───────────────┬─────────────────┘
                │
                ▼
┌─────────────────────────────────┐
│     Central Log Aggregator      │
│     (ELK/Splunk/Application)    │
└─────────────────────────────────┘
```

### 11.2 Integration Points

- Serilog sinks for various targets
- Structured JSON output for parsing
- Health check endpoint exposure
- Metrics export capability

---

## 12. Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0002 | Architecture Team | Initial definition |

---

*This document is part of the PharmaX Enterprise architectural documentation suite.*
