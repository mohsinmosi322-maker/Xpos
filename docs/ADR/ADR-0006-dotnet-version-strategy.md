# ADR-0006: Target .NET Framework Version and Compatibility Strategy

**Status:** Accepted  
**Date:** WO-0002  
**Author:** Architecture Team  
**Deciders:** Architecture Review Board  

---

## Context

PharmaX Enterprise requires a .NET platform strategy that balances modern features, long-term support, compatibility, and deployment flexibility with the following considerations:

### Business Environment

- **Target Users**: Pharmaceutical retail businesses (single pharmacy to enterprise chains)
- **Deployment Scenarios**: On-premises Windows servers, local workstations, potential cloud migration
- **Support Lifecycle**: Expected 10+ year product lifecycle
- **IT Capabilities**: Varying from small business (limited IT staff) to enterprise (dedicated IT teams)

### Technical Requirements

- Windows Forms UI framework support
- SQL Server database connectivity
- Modern C# language features
- Async/await support throughout
- Dependency injection built-in
- Cross-platform potential (future consideration)
- Performance optimization capabilities
- Security updates and patches

### Compatibility Requirements

- Windows 10/11 support (minimum)
- Windows Server 2019/2022 support
- Backward compatibility for existing Windows deployments
- Forward compatibility for future OS versions
- Third-party library ecosystem support
- Hardware peripheral compatibility (printers, scanners)

---

## Decision

We will target **.NET 8 (LTS)** as the primary runtime platform for PharmaX Enterprise with Windows Forms for the UI layer.

### Platform Choice

- **Primary Target**: .NET 8 LTS (Long-Term Support)
- **UI Framework**: Windows Forms (.NET 8)
- **Language**: C# 12
- **Minimum OS**: Windows 10 version 21H2 or later
- **Minimum Server**: Windows Server 2019 or later

### Why .NET 8 LTS Over Alternatives

| Criterion | .NET 8 LTS | .NET Framework 4.8 | .NET 6/7 |
|-----------|-----------|-------------------|----------|
| Support Duration | Nov 2026 + extensions | End of life approach | Shorter support |
| Performance | Excellent | Legacy | Good |
| C# Features | C# 12 | C# 7.3 | C# 10/11 |
| Cross-Platform | Yes | No | Yes |
| WinForms Support | Yes (modernized) | Yes (legacy) | Yes |
| Dependency Injection | Built-in | Requires packages | Built-in |
| Security Updates | Active | Minimal | Limited |
| Cloud-Native | Yes | No | Yes |

### Architecture Integration

```
┌─────────────────────────────────────────┐
│         Windows 10/11                   │
│         Windows Server 2019/2022        │
├─────────────────────────────────────────┤
│         .NET 8 Runtime                  │
│  ┌─────────────────────────────────┐   │
│  │      PharmaX.WinForms           │   │
│  │      (Presentation Layer)       │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │      PharmaX.Application        │   │
│  │      (Business Logic)           │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │      PharmaX.Domain             │   │
│  │      (Core Business Rules)      │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │      PharmaX.Infrastructure     │   │
│  │      (Data Access, Services)    │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

---

## Consequences

### Positive

1. **Long-Term Support**: .NET 8 LTS supported until November 2026 minimum, with potential extensions
2. **Modern Features**: Access to latest C# features, performance improvements
3. **Performance**: Significant performance improvements over .NET Framework
4. **Security**: Active security updates and patches
5. **Cloud-Ready**: Native support for cloud deployment scenarios
6. **Dependency Injection**: Built-in DI container reduces dependencies
7. **Cross-Platform Option**: Ability to migrate to Linux containers if needed
8. **Talent Pool**: Larger pool of developers familiar with modern .NET
9. **Package Ecosystem**: Access to modern NuGet packages
10. **Future-Proof**: Clear upgrade path to future .NET versions

### Negative

1. **Windows Forms Evolution**: WinForms in .NET 8 has differences from .NET Framework
2. **Migration Learning**: Team familiar with .NET Framework needs training
3. **Third-Party Libraries**: Some legacy libraries may not support .NET 8
4. **Deployment**: Requires .NET 8 runtime installation (mitigated by self-contained deploy)
5. **Legacy Integration**: Some older Windows integrations may require adaptation

### Mitigation Strategies

- Provide team training on .NET 8 and C# 12
- Use self-contained deployment to bundle runtime
- Evaluate third-party libraries before adoption
- Create compatibility shims for legacy integrations
- Maintain documentation of breaking changes from .NET Framework

---

## Alternatives Considered

### 1. .NET Framework 4.8

**Description**: Legacy .NET Framework, Windows-only.

**Rejected Because**:
- No new features being developed
- Limited future support
- Performance inferior to .NET Core/.NET 5+
- No cross-platform capability
- Tied to Windows OS updates
- Declining community support
- Missing modern language features
- No built-in dependency injection

### 2. .NET 6 LTS

**Description**: Previous LTS version (supported until November 2024).

**Rejected Because**:
- Shorter remaining support window
- .NET 8 has improved performance
- C# 12 features not available
- Better tooling support for .NET 8
- Starting new project on older LTS doesn't make sense

### 3. .NET 7 (Standard Term)

**Description**: Non-LTS version with shorter support.

**Rejected Because**:
- Only 18 months support
- Would require frequent upgrades
- LTS preferred for enterprise applications
- No significant advantage over .NET 8

### 4. .NET 9+ (Preview/Future)

**Description**: Next version(s) of .NET.

**Rejected Because**:
- Not yet released/stable at project start
- Should wait for LTS designation
- Prefer proven stability for enterprise
- Can upgrade after thorough testing

### 5. Dual-Target (.NET Framework + .NET 8)

**Description**: Support both frameworks via multi-targeting.

**Rejected Because**:
- Increased complexity
- Testing overhead doubled
- Conditional compilation maintenance
- Not justified for greenfield project
- Can add later if market demands

---

## Implementation Guidelines

### Project Configuration

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0-windows</TargetFramework>
    <UseWindowsForms>true</UseWindowsForms>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <LangVersion>12.0</LangVersion>
  </PropertyGroup>
</Project>
```

### Required SDKs

- .NET 8 SDK (development)
- .NET 8 Runtime (deployment)
- Windows Desktop Runtime (for WinForms)

### Minimum System Requirements

**Client Workstation**:
- Windows 10 version 21H2 or Windows 11
- 4 GB RAM minimum (8 GB recommended)
- 2 GB available disk space
- .NET 8 Desktop Runtime

**Server**:
- Windows Server 2019 or later
- 8 GB RAM minimum
- SQL Server 2019/2022 or Azure SQL

### Deployment Options

**Framework-Dependent Deployment**:
- Smaller deployment size
- Requires .NET 8 runtime installed
- Shared runtime across applications

**Self-Contained Deployment**:
- Larger deployment size (~60 MB)
- Includes .NET 8 runtime
- No prerequisites
- Recommended for most deployments

**Single-File Application**:
- Single executable
- Includes all dependencies
- Simplified deployment
- Slightly slower startup

---

## Compatibility Strategy

### Forward Compatibility

- Design with abstraction layers for easy upgrades
- Avoid deprecated APIs
- Follow Microsoft's upgrade guidance
- Test against preview releases before general availability
- Plan annual .NET version review

### Backward Compatibility

- Support last 2 Windows versions minimum
- Document OS requirements clearly
- Provide installation guides for .NET runtime
- Offer self-contained deployment option

### Library Compatibility

- Verify all NuGet packages support .NET 8
- Prefer actively maintained packages
- Avoid packages tied to .NET Framework
- Create internal wrappers for legacy dependencies

---

## Upgrade Path

### Planned Upgrade Cycle

1. **Initial Release**: .NET 8 LTS
2. **Year 1-2**: Stay on .NET 8, apply updates
3. **Year 3**: Evaluate .NET 10 LTS (when available)
4. **Major Upgrades**: Every 2-3 years aligned with LTS releases

### Upgrade Process

1. Monitor .NET release announcements
2. Test against preview releases in QA environment
3. Update development environment first
4. Run full test suite on new version
5. Performance regression testing
6. Staged rollout to production

---

## Risk Assessment

### Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| WinForms deprecation | Low | High | Monitor Microsoft roadmap; plan MAUI migration if needed |
| .NET 8 bugs | Low | Medium | Wait for .NET 8.1+ for production; monitor issues |
| Third-party library incompatibility | Medium | Medium | Evaluate early; create alternatives if needed |
| Team skill gap | Medium | Medium | Training plan; documentation; pair programming |

### Business Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Client OS incompatibility | Low | High | Clear system requirements; audit before deployment |
| Runtime installation issues | Low | Medium | Self-contained deployment option |
| Support costs | Low | Low | Leverage community; Microsoft support contract |

---

## Future Considerations

1. **.NET MAUI**: Re-evaluate for cross-platform UI if requirements change
2. **Containerization**: Docker support for server components
3. **Linux Support**: Potential for server-side Linux deployment
4. **Web Hybrid**: Blazor hybrid for specific workflows
5. **Mobile**: .NET MAUI for companion mobile apps

---

## Compliance Notes

.NET 8 supports regulatory compliance:
- FIPS-compliant cryptography
- Audit logging capabilities
- Secure configuration management
- Regular security updates
- HIPAA-compliant encryption options

---

## References

- .NET 8 Documentation: https://docs.microsoft.com/en-us/dotnet/core/whats-new/dotnet-8
- .NET Support Policy: https://dotnet.microsoft.com/en-us/platform/support/policy/
- C# 12 Features: https://learn.microsoft.com/en-us/dotnet/csharp/whats-new/csharp-12
- Windows Forms in .NET 8: https://learn.microsoft.com/en-us/dotnet/desktop/winforms/

---

*This ADR is part of the PharmaX Enterprise architectural decision record suite.*
