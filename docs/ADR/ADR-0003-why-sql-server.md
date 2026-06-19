# ADR-0003: Why SQL Server

**Status:** Accepted  
**Date:** WO-0002  
**Author:** Architecture Team  
**Deciders:** Architecture Review Board  

---

## Context

PharmaX Enterprise requires a robust, enterprise-grade relational database management system (RDBMS) with the following requirements:

### Business Requirements
- Transactional integrity for financial operations
- Complex reporting and analytics capabilities
- Multi-user concurrent access
- Data consistency across branches
- Regulatory compliance (audit trails, data retention)
- Backup and disaster recovery support
- Integration with existing pharmaceutical systems

### Technical Requirements
- ACID compliance for all transactions
- Support for stored procedures and triggers
- Full-text search capabilities
- Temporal tables for audit history
- Row-level security (future requirement)
- Always Encrypted for sensitive data
- High availability options
- Scalability from single pharmacy to enterprise chains

### Operational Requirements
- Familiar technology for IT staff
- Comprehensive tooling ecosystem
- Professional support availability
- Clear upgrade path
- Monitoring and diagnostics capabilities

---

## Decision

We will use **Microsoft SQL Server** as the primary database management system for PharmaX Enterprise.

### Version Strategy

- **Minimum Version**: SQL Server 2019 (for on-premises deployments)
- **Target Version**: SQL Server 2022 (for new deployments)
- **Cloud Option**: Azure SQL Database (for cloud-ready deployments)
- **Express Edition**: Supported for single-location deployments
- **Standard/Enterprise**: Required for multi-branch deployments

### Database Architecture

```
┌─────────────────────────────────────────┐
│         Application Layer               │
├─────────────────────────────────────────┤
│      Infrastructure (ADO.NET)           │
├─────────────────────────────────────────┤
│           SQL Server                    │
│  ┌─────────────┐  ┌─────────────┐      │
│  │   Tables    │  │   Views     │      │
│  └─────────────┘  └─────────────┘      │
│  ┌─────────────┐  ┌─────────────┐      │
│  │ Procedures  │  │  Functions  │      │
│  └─────────────┘  └─────────────┘      │
│  ┌─────────────┐  ┌─────────────┐      │
│  │  Triggers   │  │  Indexes    │      │
│  └─────────────┘  └─────────────┘      │
└─────────────────────────────────────────┘
```

---

## Consequences

### Positive

1. **Enterprise Features**: Comprehensive feature set for enterprise scenarios
2. **Tooling**: Excellent development and administration tools (SSMS, SSDT)
3. **Integration**: Seamless integration with .NET ecosystem
4. **Support**: Professional support from Microsoft
5. **Compliance**: Built-in features for regulatory compliance
6. **Performance**: Optimized query engine with excellent execution plans
7. **Security**: Advanced security features (TDE, Always Encrypted, RLS)
8. **High Availability**: Multiple HA/DR options (Always On, Log Shipping)
9. **Temporal Tables**: Built-in support for historical data tracking
10. **Backup/Restore**: Robust backup strategies with point-in-time recovery

### Negative

1. **Licensing Cost**: Commercial licensing for Standard/Enterprise editions
2. **Windows Dependency**: Best experience on Windows (though Linux supported)
3. **Resource Usage**: Can be resource-intensive for small deployments
4. **Learning Curve**: Advanced features require specialized knowledge

### Mitigation Strategies

- Use Express Edition for small deployments (free, up to 10GB)
- Provide DBA training for advanced features
- Implement connection pooling to optimize resource usage
- Use Azure SQL for pay-as-you-go pricing model

---

## Alternatives Considered

### 1. PostgreSQL

**Description**: Open-source enterprise RDBMS.

**Rejected Because**:
- Less familiar to typical .NET development teams
- Tooling ecosystem not as mature for Windows-centric shops
- Some enterprise features require third-party extensions
- Limited professional support options in our region
- Temporal table support less mature

### 2. MySQL / MariaDB

**Description**: Popular open-source RDBMS.

**Rejected Because**:
- Feature set not as comprehensive for enterprise scenarios
- ACID compliance varies by storage engine
- Advanced security features limited
- Reporting capabilities less sophisticated
- Enterprise support costs similar to SQL Server

### 3. SQLite

**Description**: Embedded file-based database.

**Rejected Because**:
- Not suitable for multi-user concurrent access
- Limited scalability
- No built-in high availability
- Insufficient security features
- No professional support option
- Only considered for local caching, not primary storage

### 4. Oracle Database

**Description**: Enterprise RDBMS.

**Rejected Because**:
- Significantly higher licensing costs
- Overkill for target deployment size
- Steeper learning curve
- Less .NET integration
- Heavier resource requirements

### 5. MongoDB / NoSQL

**Description**: Document-oriented database.

**Rejected Because**:
- ACID transactions limited (improved but not equivalent)
- Reporting complexity
- Schema-less design conflicts with compliance requirements
- Join operations less efficient
- Not suitable for financial/transactional data

---

## Implementation Guidelines

### Connection Management

- Use connection strings from secure configuration
- Implement connection pooling
- Use async/await for all database operations
- Implement retry logic for transient failures

### Security

- Use Windows Authentication where possible
- Implement least-privilege database accounts
- Enable Transparent Data Encryption (TDE)
- Use Always Encrypted for sensitive columns
- Implement row-level security when needed

### Performance

- Design appropriate indexes based on query patterns
- Use stored procedures for complex operations
- Implement query plan monitoring
- Use table partitioning for large tables
- Regular index maintenance schedules

### Compliance

- Enable temporal tables for audit history
- Implement change data capture where needed
- Configure audit logging
- Set up automated backup verification
- Document data retention policies

---

## Deployment Options

### On-Premises

- SQL Server 2019/2022 on Windows Server
- Managed by client IT team
- Client responsible for backups and maintenance

### Azure Cloud

- Azure SQL Database (PaaS)
- Managed by Microsoft
- Automatic backups and updates
- Pay-as-you-go pricing

### Hybrid

- Primary on-premises
- Azure replica for disaster recovery
- Log shipping or Always On availability groups

---

## Future Considerations

1. **Azure Migration**: Path to Azure SQL Database documented
2. **Elastic Pools**: For multi-tenant SaaS scenarios
3. **Hyperscale**: For extreme scale requirements
4. **Managed Instance**: For lift-and-shift cloud migration

---

## Compliance Notes

SQL Server supports pharmaceutical compliance:
- 21 CFR Part 11 (electronic records)
- GDPR data protection features
- HIPAA security rule compliance
- Audit trail capabilities
- Data encryption at rest and in transit

---

## References

- SQL Server Documentation: https://docs.microsoft.com/en-us/sql/
- Azure SQL Database: https://docs.microsoft.com/en-us/azure/azure-sql/
- SQL Server Security: https://docs.microsoft.com/en-us/sql/relational-databases/security/

---

*This ADR is part of the PharmaX Enterprise architectural decision record suite.*
