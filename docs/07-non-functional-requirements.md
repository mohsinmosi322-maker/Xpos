# Non-Functional Requirements

**Version:** 1.0  
**Document ID:** NFR-001  
**Created:** WO-0002  
**Related:** [Architecture Overview](./01-architecture-overview.md)

---

## 1. Introduction

This document defines the non-functional requirements (NFRs) for PharmaX Enterprise. These requirements define the quality attributes and constraints that apply across all functional modules.

---

## 2. Performance Goals

### 2.1 Response Time

| Operation Type | Target | Maximum Acceptable |
|---------------|--------|-------------------|
| UI Click Response | < 100ms | 250ms |
| Simple Query (single record) | < 200ms | 500ms |
| Complex Query (multiple joins) | < 500ms | 2000ms |
| POS Transaction Complete | < 2 seconds | 5 seconds |
| Report Generation (standard) | < 5 seconds | 30 seconds |
| Report Generation (complex) | < 30 seconds | 120 seconds |
| Batch Import (1000 records) | < 10 seconds | 60 seconds |
| Application Startup | < 5 seconds | 15 seconds |

### 2.2 Throughput

| Metric | Target |
|--------|-------|
| Concurrent Users per Branch | 50 users |
| Transactions per Second (POS) | 100 TPS |
| Database Connections | Max 100 per server |
| API Requests (future) | 1000 requests/second |

### 2.3 Resource Utilization

| Resource | Target | Maximum |
|----------|--------|---------|
| Client Memory Usage | < 256 MB | 512 MB |
| Server Memory Usage | < 4 GB | 8 GB |
| CPU Usage (average) | < 40% | 80% |
| Database Size Growth | Monitored monthly | Alert at 80% capacity |

---

## 3. Scalability Expectations

### 3.1 Vertical Scalability

- Support for increased users per branch without architectural changes
- Database server upgrade path (CPU, RAM, Storage)
- Application server resource scaling

### 3.2 Horizontal Scalability

- Multi-branch deployment support
- Database read replicas for reporting
- Load balancing capability (future web services)

### 3.3 Data Volume

| Entity | Initial | Year 1 | Year 5 |
|--------|---------|--------|--------|
| Products | 10,000 | 50,000 | 200,000 |
| Transactions/day | 1,000 | 5,000 | 25,000 |
| Customers | 5,000 | 50,000 | 500,000 |
| Sales Records/year | 365,000 | 1,825,000 | 9,125,000 |

### 3.4 Scaling Triggers

- Performance degradation > 20% from baseline
- Database size approaching 100 GB
- Concurrent users exceeding 80% of capacity
- Transaction volume exceeding design capacity

---

## 4. Availability

### 4.1 Uptime Requirements

| Component | Target Uptime | Maximum Downtime/Month |
|-----------|--------------|----------------------|
| Application (business hours) | 99.5% | 3.6 hours |
| Database Server | 99.9% | 43 minutes |
| Critical Business Functions | 99.5% | 3.6 hours |

### 4.2 Business Hours Definition

- Standard: Monday-Saturday, 8:00 AM - 10:00 PM local time
- 24/7 operations for some locations (configurable)

### 4.3 Planned Maintenance

- Scheduled during off-peak hours
- Minimum 48-hour advance notice
- Maximum 4-hour maintenance window
- Rollback plan required for all updates

---

## 5. Backup Strategy

### 5.1 Database Backup

| Backup Type | Frequency | Retention | Storage Location |
|------------|-----------|-----------|-----------------|
| Full Backup | Daily | 30 days | Off-site |
| Differential Backup | Every 6 hours | 7 days | Local + Off-site |
| Transaction Log Backup | Every 15 minutes | 7 days | Local + Off-site |

### 5.2 Application Backup

- Configuration files: Weekly full backup
- Custom reports: Included in database backup
- User templates/sessions: Not backed up (recreatable)

### 5.3 Backup Verification

- Monthly restore testing
- Quarterly full disaster recovery drill
- Automated backup success/failure notifications

### 5.4 Backup Encryption

- All backups encrypted at rest
- Encryption keys stored separately from backups
- Key rotation every 90 days

---

## 6. Disaster Recovery Objectives

### 6.1 Recovery Metrics

| Metric | Target | Maximum |
|--------|--------|---------|
| RTO (Recovery Time Objective) | 4 hours | 8 hours |
| RPO (Recovery Point Objective) | 15 minutes | 1 hour |

### 6.2 Disaster Scenarios

| Scenario | Response | Recovery Method |
|----------|----------|----------------|
| Single Server Failure | Automatic failover | HA cluster |
| Data Center Outage | Manual failover | Secondary site |
| Data Corruption | Restore from backup | Point-in-time recovery |
| Ransomware Attack | Isolate and restore | Clean backup restoration |

### 6.3 DR Documentation

- Documented recovery procedures
- Contact list for emergency response
- Regular DR testing schedule
- Post-incident review process

---

## 7. Security Requirements

### 7.1 Authentication

- Username/password with complexity requirements
- Optional Windows Authentication integration
- Session timeout after 30 minutes of inactivity
- Concurrent session limits (configurable)
- Password history (last 12 passwords remembered)

### 7.2 Authorization

- Role-Based Access Control (RBAC)
- Permission-level granularity
- Hierarchical role structure
- Audit trail for permission changes

### 7.3 Data Protection

- Encryption at rest for sensitive data
- TLS 1.2+ for data in transit
- Secure connection string storage
- No sensitive data in logs

### 7.4 Compliance

- HIPAA compliance for patient data (if applicable)
- GDPR compliance for EU customer data
- 21 CFR Part 11 for electronic records (pharmaceutical)
- SOC 2 Type II controls alignment

---

## 8. Logging Requirements

### 8.1 Log Levels

| Level | Description | Examples |
|-------|-------------|----------|
| Error | System errors requiring attention | Exceptions, failed operations |
| Warning | Potential issues | Validation failures, retries |
| Info | Significant business events | Login, transactions, configuration changes |
| Debug | Detailed diagnostic information | Method entries, query execution |
| Trace | Fine-grained debugging | Variable values, flow tracing |

### 8.2 Log Categories

- Application (business logic)
- Database (queries, connections)
- Security (authentication, authorization)
- Audit (user actions, data changes)
- Performance (timing, resource usage)

### 8.3 Log Retention

| Log Type | Retention Period | Storage |
|----------|-----------------|---------|
| Application Logs | 90 days | Local + Archive |
| Security Logs | 1 year | Local + Archive |
| Audit Logs | 7 years | Archive (immutable) |
| Performance Logs | 30 days | Local |

### 8.4 Log Format

- Structured logging (JSON format)
- Timestamp with timezone
- Correlation ID for request tracing
- User identifier (when authenticated)
- Machine/instance identifier

---

## 9. Audit Requirements

### 9.1 Auditable Events

- User login/logout
- Password changes
- Permission modifications
- Data creation, modification, deletion
- Configuration changes
- Report generation
- Export operations
- Failed access attempts

### 9.2 Audit Record Contents

| Field | Description |
|-------|-------------|
| Timestamp | Date/time of event |
| User | User who performed action |
| Action | Type of operation |
| Entity | Affected entity type |
| EntityId | Affected record ID |
| OldValue | Previous value (for updates) |
| NewValue | New value (for creates/updates) |
| IPAddress | Client IP address |
| MachineName | Client machine name |
| Success | Whether operation succeeded |

### 9.3 Audit Trail Integrity

- Immutable audit records
- No audit record deletion
- Tamper-evident storage
- Regular audit log integrity checks

---

## 10. Maintainability Goals

### 10.1 Code Quality

- Code coverage minimum: 70%
- Cyclomatic complexity maximum: 15
- Technical debt ratio: < 5%
- Zero critical security vulnerabilities
- Zero critical code smells

### 10.2 Documentation

- XML documentation for public APIs
- README for each module
- Architecture decision records
- API documentation (future)
- User manuals

### 10.3 Modularity

- Loose coupling between modules
- High cohesion within modules
- Clear module boundaries
- Independent deployability (where applicable)

### 10.4 Technical Debt Management

- Technical debt tracking in backlog
- Dedicated refactoring sprints (quarterly)
- Automated code quality gates
- Regular architecture reviews

---

## 11. Deployment Constraints

### 11.1 Supported Operating Systems

| OS | Support Level | Notes |
|----|--------------|-------|
| Windows 10 (21H2+) | Full Support | Minimum client OS |
| Windows 11 | Full Support | Recommended client OS |
| Windows Server 2019 | Full Support | Minimum server OS |
| Windows Server 2022 | Full Support | Recommended server OS |
| Windows Server 2025 | Planned Support | Upon release validation |

### 11.2 Supported SQL Server Versions

| Version | Support Level | Notes |
|---------|--------------|-------|
| SQL Server 2019 | Full Support | Minimum version |
| SQL Server 2022 | Full Support | Recommended |
| Azure SQL Database | Full Support | Cloud option |
| SQL Server Express | Limited Support | Single location only |

### 11.3 Hardware Requirements

**Client Workstation (Minimum)**:
- CPU: Dual-core 2.0 GHz
- RAM: 4 GB
- Disk: 500 MB free space
- Display: 1280x720 resolution

**Client Workstation (Recommended)**:
- CPU: Quad-core 2.5 GHz+
- RAM: 8 GB
- Disk: 1 GB free space (SSD)
- Display: 1920x1080 resolution

**Database Server (Minimum)**:
- CPU: Quad-core 2.5 GHz
- RAM: 8 GB
- Disk: 100 GB SSD
- Network: 1 Gbps

**Database Server (Recommended)**:
- CPU: 8-core 3.0 GHz+
- RAM: 32 GB
- Disk: 500 GB NVMe SSD
- Network: 10 Gbps

### 11.4 Installation Requirements

- .NET 8 Desktop Runtime (or self-contained deployment)
- SQL Server native client
- Administrator privileges for installation
- Network connectivity for activation/licensing

---

## 12. Future Cloud-Readiness Considerations

### 12.1 Cloud Migration Path

- Database abstraction supports Azure SQL migration
- Stateless application design for containerization
- Configuration externalized for environment management
- Secrets management ready for Azure Key Vault

### 12.2 Hybrid Deployment Options

- On-premises primary with cloud backup
- Cloud primary with on-premises cache
- Multi-region deployment capability

### 12.3 SaaS Considerations (Future)

- Multi-tenancy architecture support
- Tenant isolation mechanisms
- Usage metering hooks
- Self-service provisioning (future)

### 12.4 Container Readiness

- Dockerfile templates for server components
- Kubernetes manifests (future)
- Health check endpoints
- Graceful shutdown handling

---

## 13. Monitoring and Alerting

### 13.1 Application Monitoring

- Application health endpoint
- Performance counters exposure
- Custom metrics for business KPIs
- Distributed tracing (future)

### 13.2 Alert Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| Response Time | > 2 seconds | > 5 seconds |
| Error Rate | > 1% | > 5% |
| CPU Usage | > 70% | > 90% |
| Memory Usage | > 80% | > 95% |
| Disk Usage | > 80% | > 90% |
| Database Connections | > 80% capacity | > 95% capacity |

### 13.3 Notification Channels

- Email for warnings
- SMS for critical alerts
- Dashboard for real-time monitoring
- Integration with ITSM tools (future)

---

## 14. Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0002 | Architecture Team | Initial definition |

---

*This document is part of the PharmaX Enterprise architectural documentation suite.*
