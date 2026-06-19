# Git Workflow

## PharmaX Enterprise Platform

**Version:** 1.0  
**Document ID:** GIT-001  
**Created:** WO-0001  

---

## Overview

This document defines the Git branching strategy and workflow for the PharmaX Enterprise platform. All team members must follow this workflow to ensure clean version control history, proper code review, and reliable releases.

---

## Branch Types

### Main Branches

| Branch | Purpose | Protected | Lifetime |
|--------|---------|-----------|----------|
| `main` | Production-ready code | Yes | Permanent |
| `develop` | Integration branch for features | Yes | Permanent |

### Supporting Branches

| Branch Type | Prefix | Purpose | Lifetime |
|-------------|--------|---------|----------|
| Feature | `feature/` | New features or enhancements | Short-term |
| Bugfix | `bugfix/` | Non-critical bug fixes | Short-term |
| Hotfix | `hotfix/` | Critical production fixes | Short-term |
| Release | `release/` | Release preparation | Short-term |

---

## Branch Structure

```
main (production)
 │
 ├─── v1.0.0 (tag)
 │
 └─── develop (integration)
      │
      ├─── feature/WO-0002-company-module
      ├─── feature/WO-0003-branch-management
      ├─── bugfix/WO-0015-login-validation
      └─── release/v1.1.0
```

---

## Main Branches

### main

**Purpose**: Contains production-ready code only.

**Rules**:
- Only accepts merges from `release/*` or `hotfix/*` branches
- Every commit on main must be tagged with a version number
- Direct commits to main are **strictly prohibited**
- Must always build successfully
- Must pass all tests before merge

**Merge Sources**:
- `release/*` branches (normal releases)
- `hotfix/*` branches (critical fixes)

---

### develop

**Purpose**: Integration branch for all completed features.

**Rules**:
- Accepts merges from `feature/*` and `bugfix/*` branches
- Represents the latest delivered development changes
- Should build successfully at all times
- May have minor instability during active development

**Merge Sources**:
- `feature/*` branches (completed features)
- `bugfix/*` branches (non-critical fixes)

---

## Supporting Branches

### feature/*

**Purpose**: Develop new features or enhancements.

**Naming Convention**:
```
feature/<work-order>-<description>
```

**Examples**:
- `feature/WO-0002-company-module`
- `feature/WO-0005-user-authentication`
- `feature/WO-0008-role-management`

**Branch From**: `develop`  
**Merge To**: `develop`  
**Lifetime**: As long as the feature is in development (typically days to weeks)

**Workflow**:
1. Create branch from `develop`
2. Implement feature with regular commits
3. Keep branch updated with `develop` (rebase or merge)
4. Create pull request when complete
5. Address code review feedback
6. Merge to `develop` after approval
7. Delete feature branch

---

### bugfix/*

**Purpose**: Fix non-critical bugs discovered during development.

**Naming Convention**:
```
bugfix/<work-order>-<description>
```

**Examples**:
- `bugfix/WO-0012-invalid-email-validation`
- `bugfix/WO-0018-date-format-issue`

**Branch From**: `develop`  
**Merge To**: `develop`  
**Lifetime**: Days

**Workflow**:
1. Create branch from `develop`
2. Fix the bug
3. Add regression test if applicable
4. Create pull request
5. Merge after approval
6. Delete bugfix branch

---

### hotfix/*

**Purpose**: Fix critical bugs in production that require immediate attention.

**Naming Convention**:
```
hotfix/<issue-number>-<description>
```

**Examples**:
- `hotfix/ISSUE-001-login-failure`
- `hotfix/ISSUE-005-data-corruption`

**Branch From**: `main` (specifically the tagged production version)  
**Merge To**: Both `main` and `develop`  
**Lifetime**: Hours to days

**Workflow**:
1. Create branch from `main` (at production tag)
2. Fix the critical issue
3. Test thoroughly
4. Create pull request with expedited review
5. Merge to `main` and tag with patch version
6. Merge to `develop` (to include fix in future releases)
7. Delete hotfix branch

**Special Considerations**:
- Requires emergency approval (minimum 1 reviewer)
- Bypass normal release cycle
- Must be merged back to `develop` to prevent regression

---

### release/*

**Purpose**: Prepare for a new production release.

**Naming Convention**:
```
release/v<major>.<minor>.<patch>
```

**Examples**:
- `release/v1.0.0`
- `release/v1.1.0`
- `release/v2.0.0`

**Branch From**: `develop` (when feature-complete for release)  
**Merge To**: Both `main` and `develop`  
**Lifetime**: Days to weeks

**Workflow**:
1. Create branch from `develop` when ready for release
2. Perform final testing and QA
3. Fix any release-blocking issues
4. Update version numbers and changelog
5. Create pull request for `main`
6. After approval, merge to `main` and tag
7. Merge back to `develop` (to capture any fixes)
8. Delete release branch

**Activities During Release Branch**:
- Final QA testing
- Documentation updates
- Version number updates
- Changelog preparation
- Minor bug fixes only (no new features)

---

## Branch Lifecycle

### Feature Branch Lifecycle

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   develop   │────│   feature   │────│   develop   │
│             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
     │                    │                    │
     │ 1. Branch          │ 2. Develop         │ 4. Merge
     │    created              Commits            & Delete
     ▼                    ▼                    ▼
```

### Release Branch Lifecycle

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   develop   │────│   release   │────│    main     │
│             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
                        │                    │
                        │ 3. Also merge      │
                        └────────────────────┘
                              to develop
```

### Hotfix Branch Lifecycle

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    main     │────│   hotfix    │────│    main     │
│             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
                        │                    │
                        │ 3. Also merge      │
                        └────────────────────┘
                           to develop
```

---

## Commit Guidelines

### Commit Message Format

Follow the Conventional Commits specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only changes |
| `style` | Code style changes (formatting, semicolons) |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `chore` | Build process or auxiliary tool changes |
| `ci` | CI configuration changes |

### Subject Line Rules

- Use imperative mood ("add" not "added")
- Do not capitalize first letter (unless proper noun)
- No period at the end
- Maximum 50 characters

### Body Rules

- Wrap at 72 characters
- Explain what and why, not how
- Reference work orders and issues

### Examples

```
feat(company): add company CRUD operations

Implemented create, read, update, delete operations for Company entity.
- Added Company entity class
- Added ICompanyRepository interface
- Added CompanyRepository implementation
- Added CompanyApplicationService

Resolves: WO-0002
```

```
fix(auth): resolve session timeout issue

Fixed incorrect session expiry calculation that caused premature logouts.
The timeout was being calculated in seconds instead of minutes.

Fixes: ISSUE-001
```

```
docs(readme): update setup instructions

Added detailed setup instructions for new developers including:
- Prerequisites
- Database setup steps
- Configuration requirements
```

---

## Pull Request Process

### Creating a Pull Request

1. **Ensure branch is up-to-date**: Rebase or merge latest `develop`
2. **Run local tests**: Verify all tests pass
3. **Build verification**: Ensure solution builds without errors
4. **Create PR on GitHub/GitLab**: Use PR template
5. **Link work order**: Reference the WO in PR description
6. **Request reviewers**: Assign appropriate team members

### PR Template

```markdown
## Description
[Brief description of changes]

## Work Order
[WO-XXXX](link)

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

## Checklist
- [ ] Code follows project standards
- [ ] Self-review completed
- [ ] Comments added where necessary
- [ ] Documentation updated
```

### Review Requirements

| Branch Type | Minimum Reviewers | Required Approvers |
|-------------|-------------------|-------------------|
| `feature/*` | 1 | Senior Developer |
| `bugfix/*` | 1 | Team Member |
| `release/*` | 2 | Tech Lead + QA |
| `hotfix/*` | 1 | Senior Developer (expedited) |

### Merge Strategy

- **Squash and Merge**: For feature branches with multiple WIP commits
- **Merge Commit**: For release and hotfix branches (preserve history)
- **Rebase and Merge**: Only when explicitly needed (use sparingly)

---

## Version Tagging

### Semantic Versioning

Follow SemVer 2.0.0 format: `MAJOR.MINOR.PATCH`

- **MAJOR**: Incompatible API changes
- **MINOR**: Backward-compatible functionality additions
- **PATCH**: Backward-compatible bug fixes

### Tag Format

```
v<major>.<minor>.<patch>
```

### Examples

- `v1.0.0` - Initial release
- `v1.0.1` - Patch fix
- `v1.1.0` - Minor feature release
- `v2.0.0` - Major breaking changes

### Tag Creation

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to remote
git push origin v1.0.0
```

---

## Conflict Resolution

### Prevention Strategies

1. **Frequent updates**: Regularly pull/merge `develop` into feature branches
2. **Small branches**: Keep feature branches focused and short-lived
3. **Communication**: Coordinate with team on overlapping changes
4. **Clear ownership**: Define module/entity ownership

### Resolution Process

1. **Pull latest**: `git pull origin develop`
2. **Identify conflicts**: `git status`
3. **Resolve manually**: Edit conflicted files
4. **Mark resolved**: `git add <file>`
5. **Complete merge**: `git commit`
6. **Test thoroughly**: Ensure resolution works

---

## Emergency Procedures

### Hotfix Deployment

1. Create `hotfix/` branch from production tag
2. Implement minimal fix
3. Expedited review (1 senior developer)
4. Merge to `main` and tag
5. Deploy immediately
6. Merge to `develop` within 24 hours
7. Document incident

### Rollback Procedure

If a release causes issues:

1. Identify last known good tag
2. Create `hotfix/rollback-<version>` branch
3. Revert problematic changes
4. Follow hotfix process
5. Investigate root cause
6. Create bugfix for `develop` branch

---

## Repository Maintenance

### Branch Cleanup

- Delete merged feature branches immediately
- Delete release branches after tagging
- Archive old branches periodically
- Keep maximum 10 open feature branches

### Stale Branch Policy

- Branches inactive for 14 days: Warning notification
- Branches inactive for 30 days: May be deleted
- Notify branch owner before deletion

---

## Related Documents

- [Development Process](./06-development-process.md)
- [Repository Standards](./04-repository-standards.md)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | WO-0001 | Architecture Team | Initial Git workflow definition |

---

*This document is part of the PharmaX Enterprise architectural documentation suite.*
