# Security Architecture

**Version:** 1.0  
**Document ID:** SEC-001  
**Created:** WO-0002  
**Related:** [Non-Functional Requirements](./07-non-functional-requirements.md), [Error Handling](./09-error-handling.md)

---

## 1. Introduction

This document defines the security architecture for PharmaX Enterprise. Security is a cross-cutting concern that must be addressed at every layer of the application.

---

## 2. Authentication Strategy

### 2.1 Overview

PharmaX Enterprise supports multiple authentication methods:

| Method | Use Case | Priority |
|--------|----------|----------|
| Forms Authentication | Standard user login | Primary |
| Windows Authentication | Corporate/enterprise environments | Optional |
| API Key Authentication | Future service integrations | Future |

### 2.2 Forms Authentication Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    User     │     │   WinForms  │     │  Backend    │
│             │     │     UI      │     │  Services   │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       │  1. Enter Creds   │                   │
       │──────────────────>│                   │
       │                   │                   │
       │                   │  2. Validate      │
       │                   │──────────────────>│
       │                   │                   │
       │                   │  3. Generate Token│
       │                   │<──────────────────│
       │                   │                   │
       │  4. Session Start │                   │
       │<──────────────────│                   │
       │                   │                   │
```

### 2.3 Authentication Service Interface

```csharp
public interface IAuthenticationService
{
    Task<AuthenticationResult> AuthenticateAsync(string username, string password);
    Task LogoutAsync(string sessionId);
    Task<bool> ValidateSessionAsync(string sessionId);
    Task<PasswordChangeResult> ChangePasswordAsync(int userId, string currentPassword, string newPassword);
    Task RequestPasswordResetAsync(string email);
    Task<PasswordResetResult> ResetPasswordAsync(string token, string newPassword);
}
```

### 2.4 Session Management

```csharp
public interface ISessionManager
{
    string CreateSession(int userId, string ipAddress, string machineName);
    SessionInfo? GetSession(string sessionId);
    void ExtendSession(string sessionId);
    void TerminateSession(string sessionId);
    void TerminateAllUserSessions(int userId);
    int GetActiveSessionCount(int userId);
}
```

**Session Configuration**:
- Session timeout: 30 minutes of inactivity
- Maximum concurrent sessions: 3 per user (configurable)
- Session ID: Cryptographically secure random string (32 characters)
- Session storage: Database with server-side validation

---

## 3. Authorization (RBAC)

### 3.1 Role-Based Access Control Model

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Users    │────<│    Roles    │>────│ Permissions │
└─────────────┘  M:N └─────────────┘  M:N └─────────────┘
```

### 3.2 Permission Structure

```
Module.Function.Action
│      │        │
│      │        └─ Create, Read, Update, Delete, Execute, Export, Approve
│      └────────── Companies, Branches, Users, Products, Orders, etc.
└───────────────── Administration, Inventory, Sales, Finance, Reports
```

### 3.3 Standard Permissions

| Module | Permissions |
|--------|-------------|
| Companies | Companies.Read, Companies.Create, Companies.Update, Companies.Delete |
| Branches | Branches.Read, Branches.Create, Branches.Update, Branches.Delete |
| Users | Users.Read, Users.Create, Users.Update, Users.Delete, Users.ResetPassword |
| Roles | Roles.Read, Roles.Create, Roles.Update, Roles.Delete, Roles.Assign |
| Products | Products.Read, Products.Create, Products.Update, Products.Delete, Products.PriceEdit |
| Inventory | Inventory.Read, Inventory.Adjust, Inventory.Transfer, Inventory.Count |
| Sales | Sales.Read, Sales.Create, Sales.Void, Sales.Refund, Sales.Discount |
| Reports | Reports.View, Reports.Export, Reports.Administration |

### 3.4 Authorization Service

```csharp
public interface IAuthorizationService
{
    Task<bool> HasPermissionAsync(int userId, string permission);
    Task<bool> HasAnyPermissionAsync(int userId, IEnumerable<string> permissions);
    Task<bool> HasAllPermissionsAsync(int userId, IEnumerable<string> permissions);
    Task<IEnumerable<string>> GetUserPermissionsAsync(int userId);
    Task<IEnumerable<Role>> GetUserRolesAsync(int userId);
}

// Usage example
public class CompanyService
{
    private readonly IAuthorizationService _authorization;
    
    public async Task<Company> CreateCompanyAsync(CreateCompanyRequest request, int userId)
    {
        if (!await _authorization.HasPermissionAsync(userId, "Companies.Create"))
            throw new AuthorizationException("Companies.Create permission required");
        
        // Proceed with creation...
    }
}
```

### 3.5 Hierarchical Roles

```
┌─────────────────────────────────────┐
│           Super Admin               │ (All permissions)
├─────────────────────────────────────┤
│           Company Admin             │ (Company-level administration)
├──────────────┬──────────────────────┤
│ Branch Admin │    Department Lead    │ (Branch or functional admin)
├──────────────┼──────────────────────┤
│   Cashier    │  Sales Representative │ (Operational roles)
└──────────────┴──────────────────────┘
```

---

## 4. Password Hashing Approach

### 4.1 Algorithm Selection

**Primary Algorithm**: **BCrypt** with work factor 12

**Rationale**:
- Adaptive cost factor (can increase as hardware improves)
- Built-in salt generation
- Resistant to GPU/ASIC attacks
- Well-audited and widely adopted
- Available in .NET via BCrypt.Net-Next

### 4.2 Implementation

```csharp
public interface IPasswordHasher
{
    string HashPassword(string password);
    bool VerifyPassword(string password, string hash);
    bool NeedsRehash(string hash);
}

public class BCryptPasswordHasher : IPasswordHasher
{
    private const int DefaultWorkFactor = 12;
    
    public string HashPassword(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password, DefaultWorkFactor);
    }
    
    public bool VerifyPassword(string password, string hash)
    {
        return BCrypt.Net.BCrypt.Verify(password, hash);
    }
    
    public bool NeedsRehash(string hash)
    {
        // Check if hash was created with older work factor
        return !hash.StartsWith("$2a$12$"); // Example check for work factor 12
    }
}
```

### 4.3 Password Storage

```sql
CREATE TABLE Users (
    Id INT PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL,
    PasswordHash NVARCHAR(60) NOT NULL,  -- BCrypt hash length
    PasswordSalt NVARCHAR(60),           -- Included in BCrypt hash
    PasswordChangedAt DATETIME2 NOT NULL,
    -- ... other columns
);
```

---

## 5. Password Policy

### 5.1 Requirements

| Requirement | Value | Rationale |
|------------|-------|-----------|
| Minimum Length | 8 characters | Balance security/usability |
| Maximum Length | 128 characters | Prevent DoS attacks |
| Uppercase Required | Yes (1+) | Increase entropy |
| Lowercase Required | Yes (1+) | Increase entropy |
| Number Required | Yes (1+) | Increase entropy |
| Special Character | Yes (1+) | Increase entropy |
| Password History | Last 12 passwords | Prevent reuse |
| Maximum Age | 90 days | Regular rotation |
| Minimum Age | 1 day | Prevent cycling |

### 5.2 Validation Implementation

```csharp
public class PasswordPolicy
{
    private const int MinLength = 8;
    private const int MaxLength = 128;
    private const int MinHistorySize = 12;
    
    public ValidationResult ValidatePassword(string password)
    {
        var errors = new List<string>();
        
        if (string.IsNullOrEmpty(password))
            errors.Add("Password is required");
        else
        {
            if (password.Length < MinLength)
                errors.Add($"Password must be at least {MinLength} characters");
            
            if (password.Length > MaxLength)
                errors.Add($"Password cannot exceed {MaxLength} characters");
            
            if (!password.Any(char.IsUpper))
                errors.Add("Password must contain at least one uppercase letter");
            
            if (!password.Any(char.IsLower))
                errors.Add("Password must contain at least one lowercase letter");
            
            if (!password.Any(char.IsDigit))
                errors.Add("Password must contain at least one number");
            
            if (!password.Any(c => !char.IsLetterOrDigit(c)))
                errors.Add("Password must contain at least one special character");
        }
        
        return new ValidationResult(errors);
    }
}
```

---

## 6. Account Lockout

### 6.1 Lockout Policy

| Parameter | Value | Description |
|-----------|-------|-------------|
| Failed Attempts Threshold | 5 | Lock after 5 failed attempts |
| Lockout Duration | 30 minutes | Automatic unlock after 30 min |
| Reset Counter After | 15 minutes | Clear counter after 15 min of no failures |
| Progressive Lockout | Yes | Double duration on repeated lockouts |

### 6.2 Implementation

```csharp
public interface IAccountLockoutService
{
    Task RecordFailedAttemptAsync(string username);
    Task<bool> IsLockedOutAsync(string username);
    Task UnlockAccountAsync(string username);
    Task<int> GetRemainingAttemptsAsync(string username);
    Task<DateTime?> GetUnlockTimeAsync(string username);
}

public class AccountLockoutService : IAccountLockoutService
{
    private const int MaxFailedAttempts = 5;
    private const int LockoutDurationMinutes = 30;
    
    public async Task RecordFailedAttemptAsync(string username)
    {
        var lockoutInfo = await GetLockoutInfoAsync(username);
        lockoutInfo.FailedAttempts++;
        
        if (lockoutInfo.FailedAttempts >= MaxFailedAttempts)
        {
            lockoutInfo.LockedUntil = DateTime.UtcNow.AddMinutes(LockoutDurationMinutes);
            lockoutInfo.LockoutCount++;
        }
        
        await SaveLockoutInfoAsync(lockoutInfo);
        
        // Log security event
        _auditLogger.LogSecurityEvent("FAILED_LOGIN", username);
    }
    
    public async Task<bool> IsLockedOutAsync(string username)
    {
        var lockoutInfo = await GetLockoutInfoAsync(username);
        
        if (lockoutInfo.LockedUntil.HasValue && 
            lockoutInfo.LockedUntil.Value > DateTime.UtcNow)
            return true;
        
        // Auto-unlock if duration expired
        if (lockoutInfo.LockedUntil.HasValue)
        {
            await UnlockAccountAsync(username);
            return false;
        }
        
        return false;
    }
}
```

### 6.3 User Communication

```
┌─────────────────────────────────────────┐
│  Login Attempt Failed                   │
├─────────────────────────────────────────┤
│                                         │
│  Invalid username or password.          │
│                                         │
│  Attempts remaining: 3                  │
│                                         │
│         [  OK  ]                        │
│                                         │
└─────────────────────────────────────────┘
```

**Note**: Never reveal whether username exists (security by obscurity).

---

## 7. Audit Requirements

### 7.1 Security Events to Audit

| Event Category | Events | Retention |
|---------------|--------|-----------|
| Authentication | Login success, Login failure, Logout, Password change | 1 year |
| Authorization | Permission denied, Role assignment, Role modification | 1 year |
| Account Management | User created, User modified, User deleted, Account locked | 7 years |
| Data Access | Sensitive data viewed, Data exported, Bulk operations | 7 years |
| Configuration | System settings changed, Security settings modified | 7 years |

### 7.2 Audit Record Format

```csharp
public class SecurityAuditEvent
{
    public string EventType { get; set; }      // e.g., "LOGIN_SUCCESS"
    public DateTime Timestamp { get; set; }    // UTC
    public int? UserId { get; set; }           // Null for failed logins
    public string? Username { get; set; }      // For failed logins
    public string IpAddress { get; set; }      // Client IP
    public string MachineName { get; set; }    // Workstation name
    public bool Success { get; set; }          // Operation result
    public string? Details { get; set; }       // JSON additional info
    public string? FailureReason { get; set; } // If failed
}
```

---

## 8. Least-Privilege Principle

### 8.1 Application Level

- Users receive minimum permissions needed for their role
- Administrative functions separated from operational functions
- No shared accounts
- Service accounts have limited, specific permissions

### 8.2 Database Level

```
┌─────────────────────────────────────────┐
│         Database Users                  │
├─────────────────────────────────────────┤
│ phmax_app_user                          │
│   - SELECT, INSERT, UPDATE, DELETE      │
│   - Cannot DROP, TRUNCATE, ALTER        │
│                                         │
│ phmax_readonly_user                     │
│   - SELECT only                         │
│   - For reporting users                 │
│                                         │
│ phmax_admin_user                        │
│   - Full DDL permissions                │
│   - Only for DBA operations             │
└─────────────────────────────────────────┘
```

### 8.3 File System Level

- Application runs under dedicated service account
- Write access only to designated folders
- Configuration files read-only after deployment
- Log files append-only

---

## 9. Future MFA Support

### 9.1 Planned Multi-Factor Authentication

**Phase 1** (Future Release):
- TOTP (Time-based One-Time Password) support
- Compatible with Google Authenticator, Microsoft Authenticator
- Optional per-user enablement

**Phase 2** (Future Release):
- SMS verification codes
- Email verification codes
- Hardware token support (FIDO2)

### 9.2 Architecture Preparation

```csharp
// Interface designed for future MFA
public interface IMultiFactorAuthService
{
    Task<bool> IsMfaEnabledAsync(int userId);
    Task EnableMfaAsync(int userId, MfaProvider provider);
    Task DisableMfaAsync(int userId, string verificationCode);
    Task<MfaChallenge> GenerateChallengeAsync(int userId);
    Task<bool> VerifyChallengeAsync(int userId, string code);
}

public enum MfaProvider
{
    Totp,      // Authenticator app
    Sms,       // SMS message
    Email,     // Email code
    Hardware   // FIDO2 token
}
```

### 9.3 Recovery Codes

- Generate 10 single-use recovery codes when MFA enabled
- Store hashed (like passwords)
- Allow account recovery without primary MFA device
- Force MFA re-setup after recovery code use

---

## 10. Security Best Practices

### 10.1 Input Validation

- Validate all user input at entry point
- Use parameterized queries (prevent SQL injection)
- Encode output for display (prevent XSS)
- Validate file uploads (type, size, content)

### 10.2 Secure Communication

- TLS 1.2+ for all network communication
- Certificate validation enabled
- No mixed content (HTTP + HTTPS)
- Secure cipher suites only

### 10.3 Error Handling

- Never expose stack traces to users
- Generic error messages for failures
- Detailed logging for investigation
- Correlation IDs for support

### 10.4 Session Security

- Regenerate session ID after authentication
- Bind session to IP address (optional)
- Implement absolute session timeout
- Clear session data on logout

### 10.5 Defense in Depth

```
┌─────────────────────────────────────────┐
│         Perimeter Security              │
│         (Firewall, Network)             │
├─────────────────────────────────────────┤
│         Application Security            │
│         (Auth, Validation)              │
├─────────────────────────────────────────┤
│         Data Security                   │
│         (Encryption, Access Control)    │
├─────────────────────────────────────────┤
│         Physical Security               │
│         (Server Room, Hardware)         │
└─────────────────────────────────────────┘
```

---

## 11. Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0002 | Architecture Team | Initial definition |

---

*This document is part of the PharmaX Enterprise architectural documentation suite.*
