# Database Schema

# Rakshak
### Your AI Companion for Safe Digital Banking

Version: 1.0  
Status: Active

---

# Purpose

This document defines the database structure of Rakshak.

It specifies the entities, relationships, constraints, and storage responsibilities required to support the application's features.

The initial implementation uses SQLite for local storage. The schema is designed to remain compatible with PostgreSQL if cloud synchronization is introduced in future versions.

---

# Design Principles

The database follows these principles:

- Store only required information.
- Minimize sensitive data storage.
- Normalize where practical.
- Use foreign keys to maintain integrity.
- Keep AI responses separate from user settings.
- Support offline-first operation.

---

# Database Overview

The local database contains the following tables.

| Table | Purpose |
|--------|---------|
| alerts | Stores scam detection history |
| trusted_contacts | Stores emergency contacts |
| settings | Stores application preferences |
| permissions | Tracks granted permissions |
| scan_history | Stores Safe Scan results |
| recovery_actions | Stores actions taken after alerts |
| ai_cache | Stores reusable AI analysis results |

---

# Entity Relationship Diagram

```text
                 alerts
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
recovery_actions          ai_cache

trusted_contacts

settings

permissions

scan_history
```

---

# Table: alerts

Stores every scam detection event.

| Column | Type | Constraints |
|----------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| source | TEXT | NOT NULL |
| title | TEXT | |
| content | TEXT | |
| risk_level | TEXT | NOT NULL |
| confidence | REAL | |
| explanation | TEXT | |
| recommended_action | TEXT | |
| language | TEXT | DEFAULT 'en' |
| created_at | DATETIME | NOT NULL |

---

## Example

| Field | Value |
|--------|-------|
| source | WhatsApp |
| risk_level | High |
| confidence | 0.94 |

---

# Table: trusted_contacts

Stores emergency contacts selected by the user.

| Column | Type | Constraints |
|----------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| name | TEXT | NOT NULL |
| phone_number | TEXT | NOT NULL |
| relationship | TEXT | |
| notify_enabled | BOOLEAN | DEFAULT TRUE |

---

# Table: settings

Stores application configuration.

| Column | Type | Constraints |
|----------|------|-------------|
| id | INTEGER | PRIMARY KEY |
| language | TEXT | |
| dark_mode | BOOLEAN | |
| voice_enabled | BOOLEAN | |
| notification_enabled | BOOLEAN | |
| analytics_enabled | BOOLEAN | |

---

# Table: permissions

Tracks required Android permissions.

| Column | Type | Constraints |
|----------|------|-------------|
| permission_name | TEXT | PRIMARY KEY |
| granted | BOOLEAN | NOT NULL |
| granted_at | DATETIME | |

---

# Table: scan_history

Stores Safe Scan results.

| Column | Type | Constraints |
|----------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| scan_type | TEXT | NOT NULL |
| input_value | TEXT | |
| risk_level | TEXT | |
| explanation | TEXT | |
| scanned_at | DATETIME | NOT NULL |

---

Supported scan types:

- QR
- URL
- Screenshot
- Image

---

# Table: recovery_actions

Stores recovery actions performed by users.

| Column | Type | Constraints |
|----------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| alert_id | INTEGER | FOREIGN KEY alerts(id) |
| action_type | TEXT | |
| completed | BOOLEAN | |
| completed_at | DATETIME | |

---

Supported actions

- Block Number
- Contact Bank
- Report Cyber Crime
- Notify Family
- Save Evidence

---

# Table: ai_cache

Stores reusable AI analysis.

This reduces repeated API calls.

| Column | Type | Constraints |
|----------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| content_hash | TEXT | UNIQUE |
| response | TEXT | |
| confidence | REAL | |
| created_at | DATETIME | |

---

# Relationships

## alerts → recovery_actions

One alert may generate multiple recovery actions.

Relationship

One-to-Many

---

## alerts → ai_cache

Alerts may reuse cached AI responses.

Relationship

Many-to-One

---

# Primary Keys

| Table | Primary Key |
|---------|-------------|
| alerts | id |
| trusted_contacts | id |
| settings | id |
| permissions | permission_name |
| scan_history | id |
| recovery_actions | id |
| ai_cache | id |

---

# Foreign Keys

| Table | Foreign Key |
|---------|-------------|
| recovery_actions | alert_id |

---

# Indexes

Recommended indexes

alerts

- created_at
- risk_level

scan_history

- scanned_at

ai_cache

- content_hash

trusted_contacts

- phone_number

---

# Data Retention

Alert history

Retain until manually deleted.

Scan history

Retain until manually deleted.

AI cache

Automatically remove entries older than 30 days.

Recovery actions

Retain for audit purposes.

---

# Security Considerations

Never store

- OTP
- Password
- UPI PIN
- Bank account credentials
- Aadhaar number
- Card CVV

Only store information necessary for feature functionality.

---

# Backup Strategy

Current version

Local SQLite only.

Future version

Optional encrypted cloud synchronization.

---

# Migration Strategy

Version all schema changes.

Never modify existing tables without migration scripts.

Maintain backward compatibility where possible.

---

# Future Tables

Reserved for future releases.

## government_advisories

Government-issued scam alerts.

---

## merchant_reputation

Known merchant trust scores.

---

## community_reports

Crowdsourced scam reports.

---

## financial_safety_score

User protection metrics.

---

## supported_languages

Language metadata.

---

# Summary

Rakshak uses a lightweight, privacy-first relational database optimized for offline operation. The schema separates user preferences, detection history, recovery actions, and AI cache while minimizing sensitive data storage. The design supports future expansion without requiring significant structural changes.