# F-008

# F-008

## Trusted Family Mode

**Priority:** P1

**Status:** Planned

### Objective

Allow trusted family members to assist vulnerable users.

### Features

- Trusted Contacts
- High-risk Notifications
- Incident Summary
- Emergency Assistance

### Dependencies

- Contacts
- Email / Messaging Service

### Success Criteria

- Trusted contact receives notification for verified high-risk events.

---

# Shared Components

The following modules are shared across multiple features.

- AI Risk Engine
- Rule Engine
- Notification Listener
- Translation Engine
- Voice Engine
- Alert Manager
- Permission Manager
- History Manager

---

# Required Permissions

- Notification Access
- Phone State
- Overlay Permission
- Camera
- Internet
- Contacts
- Photo Picker / Storage

---

# Supported Languages

Current

- English
- Gujarati

Future

- Hindi
- Marathi
- Tamil
- Telugu
- Bengali
- Kannada

---

# Future Features (P2)

- Financial Safety Score
- Offline AI Detection
- Community Scam Reports
- Government Scam Advisory Feed
- Merchant Reputation Database
- AI Voice Assistant
- Regional Language Expansion
- Bank Integrations
- Wearable Notifications

---

# Out of Scope

Rakshak will not include:

- Antivirus
- VPN
- Password Manager
- Device Cleaner
- Browser
- Digital Wallet
- Payment Gateway
- Cloud Backup
- Battery Optimizer
- General Cybersecurity Toolkit

---

# Feature Dependencies

| Feature ID | Depends On |
|------------|------------|
| F-001 | Notification Listener, AI Risk Engine |
| F-002 | Phone State Listener, AI Risk Engine |
| F-003 | Notification Listener, Rule Engine |
| F-004 | AI Engine, Translation Engine |
| F-005 | Alert Manager |
| F-006 | Camera, AI Engine |
| F-007 | Telephony Services |
| F-008 | Contacts, Notification Service |

---

# Product Success Criteria

Rakshak will be considered successful if it can:

- Detect financial scams in real time.
- Warn users before they interact with suspicious content.
- Explain every warning in simple Gujarati or English.
- Guide users toward safe decisions.
- Provide immediate recovery assistance.
- Maintain a simple, trustworthy, and accessible user experience.
