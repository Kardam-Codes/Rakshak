# Contributing Guide

# Rakshak
### Your AI Companion for Safe Digital Banking

Version: 1.0
Status: Active

---

# Welcome

Thank you for contributing to Rakshak.

Rakshak is an AI-powered financial safety application that protects users from digital banking scams through explainable AI, local rule-based detection, and guided recovery.

This guide explains how contributors should work with the project to maintain a clean, secure, and consistent codebase.

---

# Contribution Principles

Every contribution should improve one or more of the following:

- User Safety
- Code Quality
- Performance
- Accessibility
- Maintainability
- Documentation
- Test Coverage

If a change does not improve at least one of these areas, reconsider whether it belongs in the project.

---

# Before You Start

Before writing code, read:

- README.md
- PRD.md
- FEATURE_LIST.md
- SYSTEM_DESIGN.md
- ARCHITECTURE.md
- CODING_STANDARDS.md
- TESTING_STRATEGY.md

Understanding these documents will help maintain consistency across the project.

---

# Development Environment

## Required Software

Flutter SDK

Python 3.12+

Git

Android Studio

VS Code (Recommended)

ADB

---

## Clone Repository

```bash
git clone https://github.com/your-org/rakshak.git

cd rakshak
```

---

## Frontend Setup

```bash
cd frontend

flutter pub get

flutter run
```

---

## Backend Setup

```bash
cd backend

python -m venv .venv

source .venv/bin/activate
```

Windows

```cmd
.venv\Scripts\activate
```

Install dependencies

```bash
pip install -r requirements.txt
```

Start server

```bash
uvicorn app.main:app --reload
```

---

# Branch Strategy

Never work directly on main.

Create a feature branch.

Naming convention

```
feature/

bugfix/

hotfix/

docs/

refactor/
```

Examples

```
feature/safe-scan

feature/trusted-family

bugfix/notification-parser

docs/api-spec

refactor/ai-engine
```

---

# Development Workflow

```
Create Branch

↓

Implement Feature

↓

Run Tests

↓

Update Documentation

↓

Commit Changes

↓

Push Branch

↓

Create Pull Request

↓

Code Review

↓

Merge
```

---

# Commit Message Format

Use Conventional Commits.

Format

```
type(scope): description
```

Examples

```
feat(scanner): add QR code analysis

fix(ai): improve phishing detection

docs(api): update endpoint examples

refactor(repository): simplify alert queries

test(notification): add rule engine tests

chore(ci): update workflow
```

---

# Commit Types

| Type | Purpose |
|------|----------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| refactor | Code improvement |
| style | Formatting only |
| test | Tests |
| chore | Maintenance |
| perf | Performance improvement |
| ci | CI/CD changes |

---

# Pull Request Guidelines

Every Pull Request should include:

- Clear title
- Description of changes
- Related issue (if any)
- Screenshots (UI changes)
- Test results
- Documentation updates

---

# Pull Request Checklist

Before submitting, confirm:

- Code builds successfully.
- No analyzer warnings.
- All tests pass.
- Documentation updated.
- Localization updated (if applicable).
- No hardcoded secrets.
- Error handling implemented.
- Logging added where appropriate.

---

# Code Review Expectations

Reviewers should verify:

- Architecture compliance
- Coding standards
- Test coverage
- Security implications
- Accessibility considerations
- Performance impact
- Documentation updates

Constructive feedback is encouraged.

---

# Documentation Updates

Whenever you modify:

Feature

Update:

- FEATURE_LIST.md
- Relevant feature documentation

Architecture

Update:

- ARCHITECTURE.md
- SYSTEM_DESIGN.md

API

Update:

- API_SPEC.md

AI Logic

Update:

- AI_RULES.md
- SCAM_PLAYBOOK.md

Database

Update:

- DATABASE_SCHEMA.md

Documentation should evolve with the code.

---

# Testing Requirements

Before opening a Pull Request, run:

Flutter

```bash
flutter analyze

flutter test
```

Backend

```bash
pytest
```

Fix any failing tests before submitting.

---

# Coding Standards

All code must follow:

- ARCHITECTURE.md
- CODING_STANDARDS.md

Do not introduce new patterns without team discussion.

---

# Localization

All user-facing strings must support:

- English
- Gujarati

Never hardcode visible text.

---

# Security Requirements

Never commit:

- API keys
- Secrets
- Tokens
- Passwords
- Certificates

Use

```
.env
```

Commit only

```
.env.example
```

---

# Issue Reporting

When reporting an issue, include:

- Expected behavior
- Actual behavior
- Steps to reproduce
- Device information
- Android version
- App version
- Screenshots (if applicable)
- Logs (if available)

---

# Feature Requests

Feature requests should include:

- Problem statement
- Proposed solution
- Expected user benefit
- Alternatives considered
- Impact on existing features

---

# Bug Severity

Critical

Financial safety compromised.

Immediate action required.

---

High

Major feature unavailable.

---

Medium

Feature works with limitations.

---

Low

Minor UI or usability issue.

---

# Code Ownership

Every feature should have a primary maintainer.

Suggested ownership

| Area | Owner |
|--------|--------|
| Frontend | Flutter Team |
| Backend | FastAPI Team |
| AI | AI Team |
| Documentation | All Contributors |
| Testing | QA Team |

Ownership helps coordinate reviews but does not prevent collaboration.

---

# Accessibility

Every new feature should:

- Support screen readers where appropriate.
- Respect dynamic text scaling.
- Maintain adequate color contrast.
- Use touch targets of at least 48dp.

---

# Performance Expectations

Contributors should avoid changes that:

- Increase startup time unnecessarily.
- Introduce memory leaks.
- Increase battery consumption.
- Block the UI thread.

Profile performance when introducing significant changes.

---

# Definition of Done

A task is complete only when:

- Requirements are implemented.
- Code follows architecture guidelines.
- Coding standards are satisfied.
- Tests pass.
- Documentation is updated.
- Localization is complete.
- Code review is approved.
- No critical issues remain.

---

# Communication

When discussing technical changes:

- Be respectful.
- Focus on technical reasoning.
- Document major decisions.
- Prefer evidence over assumptions.

If a significant architectural decision is made, record it in the project's architecture or decision log.

---

# License

By contributing to Rakshak, you agree that your contributions will be licensed under the project's chosen open-source or proprietary license.

---

# Thank You

Every contribution helps make digital banking safer for more people.

Whether you fix a typo, improve documentation, optimize performance, or build a new feature, your work contributes to Rakshak's mission of protecting users from financial fraud.