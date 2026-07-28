# Coding Standards

# Rakshak
### Your AI Companion for Safe Digital Banking

Version: 1.0  
Status: Active

---

# Purpose

This document defines the coding standards for Rakshak.

Its purpose is to ensure that every contributor writes clean, consistent, maintainable, and scalable code regardless of experience.

Every contributor should follow these standards before creating a Pull Request.

---

# Guiding Principles

Every line of code should be:

- Readable
- Reusable
- Testable
- Documented
- Consistent
- Secure

Code is written for humans first and computers second.

---

# General Rules

Always prefer:

- Simplicity over cleverness
- Readability over brevity
- Reuse over duplication
- Explicitness over assumptions

Avoid unnecessary abstractions until they are needed.

---

# Code Quality Rules

Code should:

- Be self-explanatory
- Have meaningful names
- Avoid duplication
- Handle errors gracefully
- Be easy to test

Never leave commented-out code.

Remove unused imports.

Remove unused variables.

Never commit debugging code.

---

# Naming Conventions

## Classes

Use PascalCase.

Examples

```
AlertService
NotificationRepository
RiskAnalysis
UserSettings
```

---

## Variables

Use camelCase.

Examples

```
riskScore
userLanguage
notificationText
trustedContacts
```

---

## Functions

Use camelCase.

Functions should start with verbs.

Examples

```
analyzeNotification()

calculateRisk()

playVoiceAlert()

saveAlert()

loadHistory()
```

---

## Constants

Use UPPER_CASE.

Examples

```
MAX_ALERT_HISTORY

DEFAULT_LANGUAGE

API_TIMEOUT

MAX_RETRY_COUNT
```

---

## Files

Use snake_case.

Examples

```
notification_service.dart

risk_card.dart

alert_repository.dart
```

---

## Folders

Use lowercase snake_case.

Examples

```
safe_scan

family_mode

alert_history
```

---

# Function Standards

Each function should perform one responsibility.

Good

```
calculateRisk()

saveAlert()

generateExplanation()
```

Avoid

```
processEverything()
```

---

# Function Length

Recommended

Less than 50 lines.

Maximum

100 lines.

If a function exceeds 100 lines, consider splitting it.

---

# File Length

Recommended

Less than 300 lines.

Maximum

500 lines.

Large files should be broken into smaller modules.

---

# Widget Standards (Flutter)

Each widget should represent one reusable component.

Avoid creating massive screen files.

Instead of

```
home_screen.dart
```

containing everything,

create

```
home_screen.dart

widgets/

risk_card.dart

quick_action.dart

recent_alert.dart
```

---

# Screen Standards

Each screen owns:

```
screen.dart

provider.dart

widgets/
```

Business logic must never exist directly inside screen files.

---

# State Management Rules

UI displays state.

Providers manage state.

Repositories provide data.

Services perform operations.

Never skip architectural layers.

---

# Comments

Write comments only when necessary.

Good comments explain "why."

Avoid comments that explain obvious code.

Good

```dart
// Cache results to avoid repeated AI requests.
```

Bad

```dart
// Increment i by one.
i++;
```

---

# Documentation

Every public class should include documentation.

Example

```dart
/// Handles notification analysis and scam detection.
class NotificationService {}
```

Public methods should include brief descriptions.

---

# Error Handling

Never ignore exceptions.

Always handle expected failures.

Provide meaningful error messages.

Avoid exposing technical details to users.

Instead of

```
SocketException
```

show

```
Unable to connect. Please check your internet connection.
```

---

# Logging

Use centralized logging.

Never use

```
print()
```

Use

```
Logger.info()

Logger.warning()

Logger.error()
```

Log

- Errors
- Warnings
- Performance events

Never log

- OTP
- Password
- UPI PIN
- Bank Account Number
- Aadhaar Number
- API Keys

---

# API Standards

Every API should return a consistent response.

Example

```json
{
  "success": true,
  "message": "Analysis completed.",
  "data": {}
}
```

Errors

```json
{
  "success": false,
  "message": "Unable to analyze notification.",
  "error": "NETWORK_ERROR"
}
```

---

# Repository Rules

Repositories are the only layer allowed to access databases.

Services must never perform SQL queries.

UI must never access repositories directly.

---

# Service Rules

Services contain business logic.

Services should never contain UI code.

Services should never navigate between screens.

---

# Model Rules

Models should contain only data.

Avoid placing business logic inside models.

---

# Localization Standards

Never hardcode user-facing text.

Instead of

```dart
Text("Safe")
```

Use

```dart
Text(AppStrings.safe)
```

Every visible string must exist in localization files.

Supported languages

- English
- Gujarati

Future languages should require minimal code changes.

---

# Security Standards

Never hardcode

- API Keys
- Secrets
- Tokens

Use

```
.env
```

Commit only

```
.env.example
```

Validate all user input.

Sanitize external data before processing.

---

# AI Coding Standards

Prompt templates should remain separate from application logic.

Never hardcode prompts inside services.

Store prompts in

```
shared/prompts/
```

AI responses should always be validated before use.

---

# Dependency Rules

Dependencies should always flow downward.

```
UI

↓

Provider

↓

Repository

↓

Service

↓

Database / AI
```

Never reverse this flow.

---

# Performance Standards

Avoid unnecessary rebuilds.

Avoid duplicate API requests.

Cache frequently used data where appropriate.

Dispose controllers when no longer needed.

Avoid blocking the UI thread.

---

# Code Reuse

Before writing new code,

Check

- Existing widgets
- Existing services
- Existing repositories
- Existing utilities

Duplicate implementations should be avoided.

---

# Import Order

Imports should follow this order.

1. Dart packages

2. Flutter packages

3. Third-party packages

4. Project packages

5. Relative imports

Separate each group with a blank line.

---

# Formatting

Indentation

2 spaces

Maximum line length

100 characters

One statement per line.

One class per file.

Always end files with a newline.

---

# Git Commit Standards

Commit messages should follow

```
type(scope): description
```

Examples

```
feat(scanner): add QR detection

fix(ai): improve phishing detection

docs(system): update architecture

refactor(alerts): simplify provider

test(api): add notification tests
```

Commit Types

- feat
- fix
- docs
- refactor
- style
- test
- chore

---

# Branch Naming

Use

```
feature/

bugfix/

hotfix/

docs/

refactor/
```

Examples

```
feature/scam-call-guardian

feature/safe-scan

bugfix/notification-parser

docs/user-flow
```

---

# Pull Request Checklist

Before submitting a Pull Request,

confirm:

- Code builds successfully
- No analyzer warnings
- No unused imports
- No commented-out code
- Documentation updated
- Localization updated
- Error handling implemented
- Logging added where appropriate
- Tests pass
- Feature manually verified

---

# Code Review Checklist

Reviewers should verify

- Correct architecture usage
- Readable code
- Naming conventions
- No duplicate logic
- Proper error handling
- Security considerations
- Localization compliance
- Performance impact
- Documentation updates

---

# Testing Expectations

Every new feature should include appropriate tests.

Recommended categories

- Unit Tests
- Widget Tests
- Integration Tests

Critical user flows must be tested before release.

---

# Accessibility Standards

Interactive elements should meet minimum touch target guidelines.

Maintain sufficient color contrast.

Support dynamic text scaling.

Ensure screen reader compatibility where applicable.

---

# Deprecation Policy

Do not remove functionality immediately.

Mark deprecated code clearly.

Provide migration paths before removal.

Remove deprecated code in a future planned release.

---

# Definition of Done

A task is considered complete only if:

- Code follows architecture guidelines
- Coding standards are followed
- Feature works as expected
- Error handling is implemented
- Localization is complete
- Documentation is updated
- Tests pass
- Code review is approved

---

# Summary

Rakshak follows a clean, modular, and security-focused coding philosophy. Every contributor is expected to write code that is readable, maintainable, reusable, and consistent with the project's architecture. Adhering to these standards ensures that the application remains reliable, scalable, and approachable for both experienced developers and new contributors.