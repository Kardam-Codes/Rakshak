# System Design

# Rakshak
### Your AI Companion for Safe Digital Banking

Version: 1.0
Status: Active

---

# Purpose

This document defines the complete technical architecture of Rakshak.

It explains how every module communicates, how data flows through the application, and how AI, backend, and Android services work together.

This document acts as the engineering blueprint for the project.

---

# Design Principles

Rakshak follows five core engineering principles.

## Privacy First

Sensitive user information should remain on the user's device whenever possible.

---

## Local First

Perform lightweight scam detection locally.

Only send data to cloud AI when necessary.

---

## Explainability

Every AI decision must include a reason.

---

## Modular Architecture

Every feature should be independently maintainable.

---

## Scalability

The system should support adding future modules without major redesign.

---

# High Level Architecture

```
                    User
                      │
                      ▼
             Flutter Android App
                      │
 ┌────────────────────┼────────────────────┐
 │                    │                    │
 ▼                    ▼                    ▼
Background      UI Layer           Local Database
Services                             (SQLite)
 │                    │                    │
 ▼                    │                    │
Notification Engine   │                    │
Call Engine           │                    │
Scanner Engine        │                    │
 │                    ▼                    │
 └────────────► AI Risk Engine ◄───────────┘
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
   Rule Engine            Gemini API
         │                       │
         └───────────┬───────────┘
                     ▼
             Risk Classification
                     │
                     ▼
             Explainability Engine
                     │
                     ▼
             Alert Manager
                     │
                     ▼
              User Notification
```

---

# Technology Stack

## Frontend

Flutter

---

## Backend

FastAPI

---

## Database

SQLite (Local)

---

## AI

Gemini API

Rule-Based Detection

---

## Local Storage

SQLite

Shared Preferences

---

## Authentication

Firebase Authentication (Future)

---

## Notifications

Android NotificationListenerService

---

## Call Detection

Android PhoneStateListener

---

# Core Modules

---

## Module 1

### Notification Engine

Responsibilities

- Monitor notifications
- Filter financial content
- Forward suspicious content to AI Risk Engine

Sources

- SMS
- WhatsApp Notifications
- Gmail Notifications
- Banking Apps
- UPI Apps

---

## Module 2

### Call Protection Engine

Responsibilities

- Detect incoming calls
- Display safety overlay
- Trigger post-call analysis

---

## Module 3

### Safe Scan Engine

Responsibilities

- Scan QR Codes
- Analyse URLs
- Analyse Images
- Analyse Screenshots

---

## Module 4

### AI Risk Engine

Responsibilities

- Calculate risk
- Detect scam patterns
- Generate explanations

Outputs

Risk Score

Risk Category

Confidence

Reason

Recommended Action

---

## Module 5

### Rule Engine

Responsibilities

Detect

- Urgency words
- Fake bank names
- Suspicious URLs
- Unknown domains
- Fake UPI requests
- Loan scam keywords

The Rule Engine acts before AI.

---

## Module 6

### Explainability Engine

Converts AI output into

Simple English

Gujarati

Voice-friendly responses

---

## Module 7

### Alert Manager

Responsibilities

Display

Popup

Notification

Voice Alert

History

Recovery

---

## Module 8

### Emergency Recovery

Provides

Block Number

Notify Family

Report Cyber Crime

Save Evidence

Contact Bank

---

# AI Processing Pipeline

```
Incoming Event

↓

Filter

↓

Rule Engine

↓

Safe?

│

├── Yes

│      Stop

│

└── No

↓

Gemini Analysis

↓

Risk Score

↓

Explanation

↓

Alert Manager

↓

User
```

---

# Local vs Cloud Processing

## Local Processing

Notification Filtering

Keyword Detection

Rule Engine

History

Permissions

Risk Cache

Voice Playback

---

## Cloud Processing

Advanced AI Analysis

Explanation Generation

Future Model Improvements

---

# Data Flow

```
Notification

↓

Notification Listener

↓

Rule Engine

↓

AI Engine

↓

Risk Classification

↓

Alert

↓

History

↓

Recovery
```

---

# Folder Responsibilities

## frontend/

Flutter UI

Navigation

Screens

Widgets

---

## backend/

FastAPI

AI APIs

Future Integrations

---

## assets/

Icons

Fonts

Illustrations

Audio

Translations

---

## shared/

Shared Constants

Prompt Templates

Schemas

---

# Database Responsibilities

SQLite stores

Alert History

Settings

Language

Trusted Contacts

Scam Logs

Permission Status

Risk Cache

---

# Backend Responsibilities

FastAPI handles

AI Requests

Future Integrations

Analytics

Scam Database

---

# Permission Flow

Required

Notification Access

Phone State

Camera

Overlay

Internet

Optional

Contacts

Gallery

---

# Security Principles

Never store OTPs.

Never store passwords.

Never store bank credentials.

Encrypt sensitive local data.

Request only required permissions.

Explain every permission.

---

# Failure Handling

If Gemini is unavailable

↓

Use Rule Engine

↓

Warn user

↓

Continue protection

---

If Internet unavailable

↓

Local Detection

↓

Offline Explanation

↓

Retry Cloud Analysis Later

---

# Scalability

Future modules should plug into the AI Risk Engine instead of creating independent detection systems.

Examples

Merchant Reputation

Government Advisory Feed

Community Reports

Voice Assistant

---

# Logging

Log

App Errors

Detection Errors

Permission Failures

API Failures

Never log

Passwords

OTPs

UPI PINs

Personal Banking Data

---

# Performance Goals

Notification analysis

< 2 seconds

Alert popup

< 1 second after analysis

App launch

< 2 seconds

Scanner response

< 3 seconds

---

# Reliability Goals

Background monitoring should continue with minimal battery impact.

The app should recover gracefully from service interruptions.

Alerts should never block normal phone usage.

---

# Future Architecture

```
Government Scam Feed
           │
           ▼

Community Reports
           │
           ▼

Merchant Reputation
           │
           ▼

──────── AI Risk Engine ────────
                │
                ▼
        Explainability Engine
                │
                ▼
            User Alert
```

---

# System Summary

Rakshak follows a modular, privacy-first architecture where Android background services monitor financial events, lightweight rule-based detection filters suspicious activity locally, AI provides explainable risk analysis when required, and a unified alert system guides users through safe decisions and recovery.