# PharmaX Enterprise Documentation

Welcome to the PharmaX Enterprise platform documentation. This directory contains all architectural documentation, standards, and processes for the project.

---

## Documentation Index

### Core Architecture

| Document | ID | Description |
|----------|-----|-------------|
| [Architecture Overview](./01-architecture-overview.md) | ARCH-001 | Overall system architecture, layers, and Clean Architecture boundaries |
| [Module Map](./02-module-map.md) | MOD-001 | Complete module definitions with responsibilities and dependencies |
| [Domain Model](./03-domain-model.md) | DOM-001 | Conceptual domain model with entities, relationships, and business rules |

### Standards & Guidelines

| Document | ID | Description |
|----------|-----|-------------|
| [Repository Standards](./04-repository-standards.md) | STD-001 | Coding standards, naming conventions, and layer responsibilities |
| [Git Workflow](./05-git-workflow.md) | GIT-001 | Branching strategy, commit guidelines, and pull request process |
| [Development Process](./06-development-process.md) | DEV-001 | Work management, code review, QA, and release procedures |
| [Non-Functional Requirements](./07-non-functional-requirements.md) | NFR-001 | Performance, scalability, availability, security, and compliance requirements |
| [Coding Standards](./08-coding-standards.md) | CODE-001 | Naming conventions, SOLID principles, DI, exception handling, and code quality |
| [Error Handling](./09-error-handling.md) | ERR-001 | Exception hierarchy, UI error handling, logging, and recovery strategies |
| [Logging Strategy](./10-logging-strategy.md) | LOG-001 | Log levels, categories, structured logging, retention, and audit logging |
| [Security Architecture](./11-security-architecture.md) | SEC-001 | Authentication, authorization (RBAC), password policy, MFA roadmap |
| [Database Standards](./12-database-standards.md) | DB-001 | Naming conventions, indexing, transactions, SQL coding standards |

### Architecture Decision Records (ADR)

Significant architectural decisions are documented in ADRs located in `/docs/ADR/`.

| ADR | Title | Status |
|-----|-------|--------|
| [ADR-0001: Why Clean Architecture](./ADR/ADR-0001-why-clean-architecture.md) | Accepted |
| [ADR-0002: Why Windows Forms](./ADR/ADR-0002-why-windows-forms.md) | Accepted |
| [ADR-0003: Why SQL Server](./ADR/ADR-0003-why-sql-server.md) | Accepted |
| [ADR-0004: Why ADO.NET Instead of Entity Framework](./ADR/ADR-0004-why-ado-net.md) | Accepted |
| [ADR-0005: Why Repository Pattern + Unit of Work](./ADR/ADR-0005-why-repository-pattern.md) | Accepted |
| [ADR-0006: Target .NET Framework Version and Compatibility Strategy](./ADR/ADR-0006-dotnet-version-strategy.md) | Accepted |

### For New Team Members

1. **Start Here**: Read the [Architecture Overview](./01-architecture-overview.md) to understand the system structure
2. **Understand the Domain**: Review the [Domain Model](./03-domain-model.md) for business concepts
3. **Learn the Standards**: Study the [Repository Standards](./04-repository-standards.md) for coding guidelines
4. **Setup Git**: Follow the [Git Workflow](./05-git-workflow.md) for version control

### For Developers

- Before starting work: Review the [Module Map](./02-module-map.md) to understand your module's context
- During development: Follow the [Repository Standards](./04-repository-standards.md)
- Before committing: Check the [Git Workflow](./05-git-workflow.md) for commit message format
- Before merging: Verify against the [Definition of Done](./06-development-process.md#definition-of-done-dod)

### For Code Reviewers

- Use the [Code Review Checklist](./06-development-process.md#review-checklist)
- Verify adherence to [Repository Standards](./04-repository-standards.md)
- Check [Git Workflow](./05-git-workflow.md) compliance for commits and PRs

---

## Document Versioning

All documents follow semantic versioning:
- **Major**: Significant architectural changes
- **Minor**: Additions or clarifications
- **Patch**: Typos and minor corrections

Each document includes a version history table at the end.

---

## Architecture Decision Records (ADR)

Significant architectural decisions are documented in ADRs located in `/docs/adr/`.

Current ADRs:
- None yet (to be created as needed)

---

## Work Orders

Work is tracked using Work Orders (WO). Current status:

| WO | Title | Status | Module |
|-----|-------|--------|--------|
| WO-0001 | Establish Foundation & Domain Architecture | ✅ Done | All |
| WO-0002 | Implement Company Module | 📋 Planned | Company |
| WO-0003 | Implement Branch Module | 📋 Planned | Branch |

*Status: 📋 Planned | 🔄 In Progress | ✅ Done*

---

## Contributing to Documentation

When updating documentation:

1. Update the version number and date in the document header
2. Add an entry to the Document History table
3. Update this index if adding new documents
4. Commit with message: `docs(<doc>): <description>`

Example:
```
docs(architecture): add performance considerations section

Added new section covering caching strategies and database 
optimization techniques.

Resolves: WO-0001
```

---

## Related Resources

- Main Repository: `/`
- Source Code: `/src/` (to be created)
- Tests: `/tests/` (to be created)

---

## Contact

For questions about this documentation:
- Architecture Team: [TBD]
- Tech Lead: [TBD]

---

**Last Updated**: WO-0001  
**Document Owner**: Architecture Team

---

*This documentation suite is part of the PharmaX Enterprise platform.*
