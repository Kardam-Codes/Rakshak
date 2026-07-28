# Testing Strategy

# Rakshak
### Your AI Companion for Safe Digital Banking

Version: 1.0
Status: Active

---

# Purpose

This document defines the testing strategy for Rakshak.

It establishes the quality assurance process for every feature, module, API, AI component, and release.

The objective is to ensure Rakshak remains reliable, secure, performant, and trustworthy while protecting users from financial scams.

---

# Testing Objectives

Every release should verify that:

- Features work correctly.
- AI produces consistent and explainable results.
- False positives remain minimal.
- False negatives remain minimal.
- Performance meets defined targets.
- Accessibility requirements are satisfied.
- Security requirements are maintained.

---

# Testing Philosophy

Rakshak follows multiple layers of testing.

```
Unit Tests
      ↓
Integration Tests
      ↓
Widget Tests
      ↓
System Tests
      ↓
AI Evaluation
      ↓
Performance Tests
      ↓
Security Tests
      ↓
Regression Tests
      ↓
Release Validation
```

Every layer should pass before a release.

---

# Testing Pyramid

```
                Manual Testing
                     ▲
              End-to-End Tests
                     ▲
           Integration Tests
                     ▲
               Widget Tests
                     ▲
                Unit Tests
```

Most tests should exist at the lower levels.

---

# Test Environments

Development

Used during implementation.

---

Testing

Used for QA validation.

---

Staging

Production-like environment.

---

Production

Release environment.

Only fully validated builds should reach production.

---

# Unit Testing

Purpose

Verify individual functions and classes.

Examples

- Risk calculation
- Rule engine
- Utility functions
- Validators
- Repositories
- Services

Target Coverage

Minimum 80%

Recommended 90%

---

# Widget Testing

Purpose

Verify reusable Flutter widgets.

Examples

- Risk Card
- Alert Tile
- Primary Button
- Language Selector
- Safety Banner

Tests should verify

- Rendering
- User interaction
- State updates

---

# Integration Testing

Purpose

Verify communication between modules.

Examples

Notification Service

↓

AI Service

↓

Alert Repository

↓

UI Update

---

Scanner

↓

Analysis

↓

Alert

↓

History

---

# End-to-End Testing

Purpose

Validate complete user journeys.

Critical scenarios

- First-time onboarding
- Scam notification detection
- Safe Scan
- QR analysis
- Recovery workflow
- Trusted Family notification
- Settings update

---

# API Testing

Every endpoint should verify

- Successful requests
- Invalid input
- Missing fields
- Authentication
- Rate limits
- Error responses

Example

POST

/analyze/notification

Test

- Valid notification
- Empty notification
- Invalid JSON
- Large payload
- Unsupported language

---

# Database Testing

Verify

- CRUD operations
- Foreign keys
- Indexes
- Data integrity
- Migration compatibility

---

# AI Evaluation

The AI should be evaluated using a curated dataset.

Categories

- Legitimate banking messages
- Scam messages
- Mixed-language messages
- Gujarati messages
- Fake UPI requests
- QR scams
- Fake refunds
- Fake KYC
- Investment scams
- Lottery scams

---

# AI Metrics

Track

Precision

Recall

Accuracy

F1 Score

False Positive Rate

False Negative Rate

Average Confidence

Average Response Time

---

# AI Acceptance Criteria

Recommended targets

| Metric | Target |
|----------|---------|
| Precision | ≥ 95% |
| Recall | ≥ 90% |
| False Positive Rate | < 5% |
| False Negative Rate | < 5% |
| Average Response Time | < 3 seconds |

---

# Rule Engine Testing

Verify

- Keyword detection
- URL detection
- Domain matching
- Risk scoring
- Offline behavior

Each rule should have positive and negative test cases.

---

# Scam Dataset Validation

Maintain separate datasets.

Positive Dataset

Known scam examples.

Negative Dataset

Legitimate banking communication.

Mixed Dataset

Borderline cases.

Every release should run against all datasets.

---

# Localization Testing

Supported languages

- English
- Gujarati

Verify

- Text rendering
- Layout
- Voice output
- AI explanations
- Date formatting

---

# Accessibility Testing

Verify

- Screen reader compatibility
- Dynamic text scaling
- Color contrast
- Touch target size
- Keyboard navigation (where applicable)

---

# Performance Testing

Measure

App Launch Time

Target

< 2 seconds

---

Notification Detection

Target

< 100 ms

---

AI Analysis

Target

< 3 seconds

---

Alert Display

Target

< 1 second after analysis

---

Scanner Analysis

Target

< 3 seconds

---

Memory Usage

Maintain stable memory usage during extended monitoring.

---

Battery Testing

Background monitoring should have minimal battery impact.

Test

- 1 hour
- 6 hours
- 24 hours

Measure

- Battery consumption
- Background service stability

---

# Offline Testing

Verify

- Rule engine continues working
- History remains available
- Settings remain editable
- Scanner handles offline state gracefully

---

# Network Testing

Test

- Fast connection
- Slow connection
- High latency
- No internet
- Connection interruption

---

# Security Testing

Verify

- Secure local storage
- Input validation
- API validation
- Secret management
- HTTPS enforcement
- Sensitive data masking

Confirm that the application never stores

- OTP
- UPI PIN
- Password
- Card PIN
- CVV

---

# Permission Testing

Verify

- Notification permission denied
- Camera denied
- Phone state denied
- Overlay denied

Application should degrade gracefully.

---

# Regression Testing

Before every release

Run

- Unit tests
- Widget tests
- Integration tests
- AI evaluation
- Manual smoke tests

Previously fixed issues must remain resolved.

---

# Smoke Testing

Essential functionality

- Launch app
- Open Home
- Analyze notification
- Scan QR
- Open History
- Update Settings
- Emergency Recovery

Expected Result

No crashes.

---

# User Acceptance Testing

Representative users should verify

- Ease of onboarding
- Clarity of explanations
- Ease of recovery
- Gujarati translations
- Voice guidance

Feedback should be documented before release.

---

# Test Data Management

Maintain separate datasets for

Development

Testing

Production

Never use real banking credentials or personal financial data.

---

# Bug Severity Levels

Critical

Data loss or financial safety failure.

Release blocker.

---

High

Major feature unusable.

---

Medium

Feature works with limitations.

---

Low

Minor UI or usability issue.

---

# Exit Criteria

A release is ready when

- All critical tests pass
- No critical defects remain
- No high-priority defects remain
- AI metrics meet targets
- Performance targets are achieved
- Documentation is updated

---

# Continuous Testing

Testing should occur

- During development
- Before merge
- Before release
- After major dependency updates
- After AI model updates

---

# Automation Goals

Automate

- Unit tests
- Widget tests
- Integration tests
- API tests
- Static analysis
- Formatting checks

Manual testing should focus on usability, accessibility, and exploratory scenarios.

---

# Testing Tools

Recommended tools

Flutter

- flutter_test
- integration_test
- mocktail

Backend

- pytest
- pytest-asyncio
- httpx

API

- Postman
- Bruno

Quality

- flutter analyze
- dart format
- ruff
- mypy

CI/CD

- GitHub Actions

---

# Summary

Rakshak follows a layered testing strategy combining automated and manual validation to ensure reliability, security, accessibility, and AI quality. Every release must satisfy functional, performance, security, and usability requirements before deployment, providing users with a trustworthy financial safety companion.