# Architecture

# Rakshak
### Your AI Companion for Safe Digital Banking

Version: 1.0
Status: Active

---

# Purpose

This document defines the software architecture of Rakshak.

It establishes how the project is organized, how modules communicate, where new code should be placed, and the engineering conventions every contributor must follow.

This document exists to ensure long-term maintainability, scalability, and consistency across the codebase.

---

# Architecture Philosophy

Rakshak follows five core principles.

- Feature First
- Modular
- Scalable
- Testable
- AI-Friendly

Every feature should be independently understandable.

Every developer should know exactly where new code belongs.

---

# Project Structure

```

Rakshak/

├── docs/
├── frontend/
├── backend/
├── assets/
├── shared/
└── scripts/

```

---

# Frontend Structure

```

frontend/

lib/

├── core/
├── config/
├── models/
├── services/
├── repositories/
├── providers/
├── widgets/
├── screens/
├── routes/
├── utils/
├── localization/
└── main.dart

```

---

# Core Layer

Contains reusable project-wide functionality.

Examples

- Theme
- Constants
- Colors
- Typography
- Permission Manager
- Logger
- Error Handler

No business logic should exist here.

---

# Config Layer

Stores application configuration.

Examples

API URLs

Environment

Feature Flags

Build Configuration

---

# Models Layer

Contains pure data models.

Examples

User

Alert

Notification

RiskAnalysis

FamilyMember

Never place business logic inside models.

---

# Services Layer

Responsible for interacting with platform APIs and external systems.

Examples

Notification Service

Phone Service

Camera Service

Voice Service

Storage Service

Permission Service

Internet Service

---

# Repository Layer

Acts as the bridge between UI and data sources.

Repositories decide where data comes from.

Examples

AlertRepository

UserRepository

SettingsRepository

ScanRepository

AIRepository

---

# Provider Layer

Responsible for application state.

Each feature should have its own provider.

Examples

HomeProvider

AlertProvider

ScanProvider

FamilyProvider

SettingsProvider

---

# Widgets Layer

Reusable UI components.

Examples

Risk Card

Primary Button

Safety Banner

Alert Tile

Language Selector

Voice Button

No screen-specific logic.

---

# Screens Layer

Every screen belongs to one feature.

```

screens/

home/

alerts/

scanner/

family/

emergency/

history/

settings/

onboarding/

```

Each folder contains

```

screen.dart

widgets/

provider.dart

```

---

# Routes Layer

Centralized navigation.

Never hardcode routes.

---

# Localization Layer

Contains

English

Gujarati

Future languages

All visible strings must come from localization files.

Never hardcode user-facing text.

---

# Backend Structure

```

backend/

app/

├── api/
├── services/
├── ai/
├── database/
├── repositories/
├── models/
├── schemas/
├── middleware/
├── utils/
├── config/
└── main.py

```

---

# API Layer

Contains only endpoint definitions.

Business logic should never exist here.

---

# Services Layer

Implements application logic.

Examples

Notification Analysis

UPI Analysis

Recovery Service

Family Service

---

# AI Layer

Contains

Prompt Templates

Risk Analysis

Scam Classification

Explainability

Language Generation

This is the only layer that interacts with the Local SLM.

---

# Database Layer

Contains

Connection

Initialization

Migrations

Seed Data

---

# Repository Layer

Handles all database access.

Never query SQLite directly from services.

---

# Models Layer

Database entities.

Alert

User

History

Settings

---

# Schemas Layer

Request

Response

Validation

DTOs

---

# Middleware Layer

Authentication

Logging

Error Handling

Request Validation

---

# Shared Folder

Contains resources used by both frontend and backend.

Examples

JSON Constants

Prompt Templates

Schemas

Bank Lists

Trusted Domains

Risk Keywords

Carrier Codes

---

# Assets Structure

```

assets/

icons/

fonts/

illustrations/

animations/

audio/

translations/

```

---

# Naming Conventions

Folders

lowercase

snake_case

Files

snake_case

Classes

PascalCase

Variables

camelCase

Constants

UPPER_CASE

Private variables

_prefix

---

# Feature Isolation

Every feature should own

UI

Provider

Repository

Models

Widgets

Services

Adding a new feature should require minimal changes elsewhere.

---

# Dependency Direction

```

Screen

↓

Provider

↓

Repository

↓

Service

↓

Database / AI / Platform

```

Never reverse this dependency.

---

# State Management

Single source of truth.

UI must never contain business logic.

State updates happen only inside Providers.

---

# Error Handling

Every async operation returns

Success

Failure

Loading

Never throw unhandled exceptions to the UI.

---

# Logging

Use a centralized logger.

Never use print() statements.

Log

Errors

Warnings

Performance

Never log

Passwords

OTP

UPI PIN

Bank Credentials

---

# Configuration Management

Secrets must never be committed.

Use

.env

for

API Keys

Tokens

Environment Variables

Commit only

.env.example

---

# AI Development Guidelines

AI-generated code must

Follow folder structure

Use existing components

Reuse services

Avoid duplicate logic

Never bypass repositories

Follow naming conventions

---

# Code Review Checklist

Before merging

✔ Correct folder

✔ Naming conventions

✔ Reused existing widgets

✔ No duplicate code

✔ No hardcoded strings

✔ Localized text

✔ Error handling

✔ Logging

✔ Documentation updated

---

# Scalability Rules

Adding a new feature must not require modifying existing features unless absolutely necessary.

Each feature should be independently testable.

Each module should expose a clean public interface.

---

# Architecture Summary

Rakshak follows a modular, feature-first architecture with clear separation between presentation, business logic, data access, and AI services. Every module is designed to remain independent, reusable, and scalable while maintaining a clean codebase that is easy for both developers and AI assistants to understand.