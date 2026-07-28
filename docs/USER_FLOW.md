# User Flow

# Rakshak
### Your AI Companion for Safe Digital Banking

Version: 1.0  
Status: Active

---

# Purpose

This document defines how users interact with Rakshak.

It describes every major user journey from installation to scam recovery.

This document should be used by:

- UI Designers
- Frontend Developers
- Backend Developers
- AI Engineers
- QA Testers

---

# User Journey Philosophy

Rakshak exists to protect users in three stages:

1. Before a Scam
2. During a Scam
3. After a Scam

Every feature must belong to at least one of these stages.

---

# Overall User Journey

```
Install Rakshak
        │
        ▼
Grant Required Permissions
        │
        ▼
Background Protection Starts
        │
        ▼
────────────────────────────────────
User Uses Phone Normally
────────────────────────────────────
        │
        ▼
Scam Detected?
     │          │
    No         Yes
     │          │
     │          ▼
     │    AI Analysis
     │          │
     │          ▼
     │   Risk Classification
     │          │
     │          ▼
     │   User Alert + Explanation
     │          │
     │          ▼
     │   Recommended Actions
     │          │
     │          ▼
     │  Recovery (if required)
     │
     ▼
Continue Monitoring
```

---

# First-Time User Flow

Launch App

↓

Welcome Screen

↓

Choose Language

- English
- ગુજરાતી

↓

Privacy Overview

↓

Grant Permissions

- Notification Access
- Phone State
- Overlay
- Camera
- Contacts (Optional)

↓

Setup Trusted Contact (Optional)

↓

Rakshak Activated

↓

Home Screen

---

# Home Screen Flow

Open App

↓

Financial Protection Status

↓

Choose Action

- Scan Something
- View Alerts
- Emergency Help
- Manage Family
- Settings

↓

Return Home

---

# AI Scam Guardian Flow

Background Monitoring

↓

New Notification Received

↓

Notification Filter

↓

Financial Content?

│

├── No

│       Ignore

│

└── Yes

↓

AI Risk Analysis

↓

Rule Engine Verification

↓

Risk Score Generated

↓

Risk Category

Safe

↓

No Alert

OR

Suspicious

↓

Warning Card

OR

Dangerous

↓

Popup + Voice Alert

↓

Alert Saved to History

---

# Scam Call Guardian Flow

Incoming Call

↓

Known Contact?

│

├── Yes

│       No Action

│

└── Unknown

↓

Display Safety Overlay

↓

User Completes Call

↓

Post-call Questions

↓

AI Risk Assessment

↓

Safe?

│

├── Yes

│      Save

│

└── No

↓

Suggest Actions

- Block
- Report
- Learn More

↓

Save Incident

---

# Smart UPI Protection Flow

UPI Notification

↓

Detect Type

- Payment
- Collect Request
- Refund
- QR Payment

↓

AI Analysis

↓

Risk Level

↓

Explain

"You are about to PAY."

OR

"You are RECEIVING money."

↓

Suggested Action

↓

Save Alert

---

# Safe Scan Flow

User Opens Safe Scan

↓

Choose Input

- QR Code
- Link
- Screenshot
- Image

↓

AI Analysis

↓

Risk Classification

↓

Explanation

↓

Suggested Action

↓

Return Home

---

# Emergency Recovery Flow

High Risk Alert

↓

Open Recovery Assistant

↓

Choose Action

- Block Number
- Contact Bank
- Report Cyber Crime
- Notify Trusted Contact
- Save Evidence

↓

Confirmation

↓

Return Home

---

# Trusted Family Flow

Open Family Mode

↓

Add Trusted Contact

↓

Verify Contact

↓

Monitoring Enabled

↓

High Risk Event

↓

Incident Summary Sent

↓

Trusted Contact Notified

---

# OTP Forwarding Protection Flow

Open Protection Module

↓

Check Forwarding Status

↓

Forwarding Enabled?

│

├── No

│      Device Safe

│

└── Yes

↓

Show Warning

↓

Carrier Instructions

↓

Disable Forwarding

↓

Verification

---

# Alert Details Flow

Open Alert

↓

Risk Level

↓

Why?

↓

Recommended Action

↓

Voice Explanation

↓

Take Action

↓

Close

---

# Notification History Flow

History

↓

Select Alert

↓

View Details

↓

Replay Explanation

↓

Delete (Optional)

---

# Offline Flow

Internet Available?

│

├── Yes

│      Full AI Analysis

│

└── No

↓

Rule-Based Detection

↓

Offline Warning

↓

Store Request

↓

Re-analyse Later (Optional)

---

# Permission Denied Flow

Permission Required

↓

Granted?

│

├── Yes

│      Continue

│

└── No

↓

Explain Why

↓

Retry

↓

Continue with Limited Protection

---

# False Positive Flow

User Marks

"This is Safe"

↓

Feedback Stored

↓

Future AI Improvement

---

# Voice Explanation Flow

Alert Generated

↓

User Presses Speaker

↓

Language Selected

↓

Play Voice

↓

Stop

↓

Replay (Optional)

---

# Error Flow

Analysis Failed

↓

Show Friendly Message

↓

Retry

↓

If still unsuccessful

↓

Suggest Manual Verification

---

# Navigation Flow

```
Home
│
├── Alerts
│
├── Safe Scan
│
├── History
│
└── Profile
```

---

# User States

## Protected

Background monitoring active.

---

## Warning

Suspicious activity detected.

---

## Danger

Immediate action recommended.

---

## Recovery

User taking corrective action.

---

# Completion Criteria

A successful user journey should ensure that:

- The user understands the threat.
- The user knows why it was detected.
- The user receives simple guidance.
- The user can recover quickly.
- The user never feels overwhelmed.

---

# Design Rules for Every Flow

Every flow must:

- Require the fewest possible taps.
- Avoid technical language.
- Explain before requesting action.
- Offer a safe next step.
- Keep users calm.
- Support Gujarati and English.
- Be accessible to first-time smartphone users.

---

# Future User Flows

Reserved for future releases:

- AI Voice Assistant
- Community Scam Reports
- Government Scam Advisory Feed
- Financial Safety Score
- Regional Language Expansion