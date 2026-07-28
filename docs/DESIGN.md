# Design System

# Rakshak
### Your AI Companion for Safe Digital Banking

Version: 1.0  
Status: Active

---

# Purpose

This document defines the complete design language of Rakshak.

Its purpose is to ensure that every screen, component, interaction, animation, and AI-generated UI follows a single consistent visual identity.

The design philosophy prioritizes clarity, trust, accessibility, and simplicity over visual complexity.

---

# Design Philosophy

Rakshak is **not** a cybersecurity dashboard.

Rakshak is a trusted digital companion.

Users should feel:

- Safe
- Calm
- Guided
- Confident

Never overwhelmed.

Every screen should answer one simple question:

> "What is the safest thing for the user to do next?"

---

# Design Principles

## Trust First

The interface should inspire confidence.

Avoid flashy effects or aggressive security aesthetics.

---

## Simplicity Over Features

Never place too many actions on one screen.

If a feature requires explanation, redesign it.

---

## Explain Before Asking

Every warning should explain why it exists before asking the user to take action.

---

## Accessibility by Default

Large touch targets.

Readable fonts.

Minimal typing.

Voice assistance wherever appropriate.

---

## Calm, Not Fear

Avoid creating panic.

Instead of:

❌ "YOUR PHONE IS UNDER ATTACK"

Use:

⚠ "This message appears suspicious."

---

# Visual Inspiration

Rakshak draws inspiration from:

- Google Wallet (Home Dashboard)
- Google Personal Safety (Emergency Flows)
- Google Family Link (Family Management)
- Google Messages (Scam Warnings)
- Google Files (Scanner Experience)

These applications share a common philosophy:

Simple.

Friendly.

Trustworthy.

---

# Color System

## Primary

Purpose:

Brand Identity

```
#1565C0
```

---

## Success

Purpose:

Safe

```
#2E7D32
```

---

## Warning

Purpose:

Suspicious

```
#F9A825
```

---

## Danger

Purpose:

High Risk

```
#D32F2F
```

---

## Information

Purpose:

Neutral Guidance

```
#0288D1
```

---

## Background

```
#F8FAFC
```

---

## Surface

```
#FFFFFF
```

---

## Divider

```
#E2E8F0
```

---

## Primary Text

```
#1E293B
```

---

## Secondary Text

```
#64748B
```

---

# Typography

Primary Font

**Poppins**

Fallback

Inter

System Sans

---

# Typography Scale

Display

32sp

---

Heading

24sp

---

Subheading

20sp

---

Body

16sp

---

Caption

14sp

---

Small Label

12sp

---

# Icon System

Use:

Material Symbols Rounded

Never mix icon libraries.

---

# Elevation

Cards

4dp

Dialogs

8dp

Bottom Sheets

12dp

Floating Buttons

6dp

---

# Border Radius

Buttons

16dp

Cards

20dp

Dialogs

24dp

Bottom Sheets

28dp

Input Fields

16dp

---

# Spacing System

Base Unit

8dp

Common Spacing

8

16

24

32

40

48

Never use arbitrary spacing.

---

# Buttons

## Primary Button

Filled

Blue

White Text

Large

Rounded

---

## Secondary Button

Outlined

Blue Border

White Background

---

## Danger Button

Red Filled

Used only for destructive actions.

---

## Text Button

No background.

Used for low-priority actions.

---

# Cards

Cards should contain

Icon

Title

Short Description

Primary Action

Never place more than two actions inside one card.

---

# Risk Indicators

Safe

🟢 Green

---

Suspicious

🟡 Yellow

---

Dangerous

🔴 Red

---

Never rely only on color.

Always include text and icons.

---

# Alert Language

Never use technical words.

Instead of:

"Phishing URL"

Use:

"This website may try to steal your information."

---

Instead of:

"Credential Theft"

Use:

"This message may ask for your bank details."

---

# Illustrations

Style

Flat

Minimal

Friendly

No 3D

No cartoon mascots

No hacker imagery

No shields with flames

No matrix backgrounds

---

# Animations

Purpose

Guide attention.

Never entertain.

Use animations for

Loading

Success

Transitions

Alert Appearance

Keep durations between

200–300 ms

---

# Navigation

Bottom Navigation

Maximum

5 Tabs

Recommended

Home

Alerts

Scanner

History

Profile

---

# Screen Layout

Each screen should contain

App Bar

Primary Content

Primary Action

Secondary Action (optional)

Bottom Navigation

Avoid nested navigation whenever possible.

---

# Home Screen Structure

1. Financial Safety Status

2. AI Protection Status

3. Quick Actions

4. Recent Alerts

5. Trusted Family

Keep the most important information above the fold.

---

# Safe Scan Screen

Single entry point.

Supports

- QR Code
- URL
- Screenshot
- Image

Users should never need to choose different scanners.

---

# Alert Screen

Every alert must include

Risk Level

Explanation

Reason

Recommended Action

Voice Playback

Never show only a warning.

---

# Emergency Screen

Priority Actions

1. Block Number

2. Contact Bank

3. Report Cyber Crime

4. Notify Family

5. Save Evidence

Buttons must be large enough for elderly users.

---

# Accessibility

Minimum touch target

48dp

Support screen readers.

Support dynamic text scaling.

Maintain high color contrast.

Voice playback available where possible.

---

# Dark Mode

Supported.

Do not simply invert colors.

Maintain contrast and readability.

---

# Empty States

Every empty state should educate.

Example

"No scam alerts yet."

Instead of showing nothing,

show

"Rakshak is actively protecting your device."

---

# Error States

Never blame the user.

Instead of

"You entered an invalid URL."

Use

"We couldn't check this link. Please try again."

---

# Loading States

Use skeleton loaders where appropriate.

Avoid indefinite loading indicators.

---

# Microcopy Guidelines

Write as if speaking to a family member.

Examples

Good:

"This message looks suspicious."

Good:

"Take a moment before continuing."

Bad:

"Potential credential harvesting attempt detected."

---

# Voice Guidelines

Voice should be

Friendly

Calm

Clear

Slow enough for elderly users

Avoid robotic wording.

---

# Design Consistency Rules

Every new screen must:

Use the same spacing system.

Use approved colors.

Use approved typography.

Use Material Symbols Rounded.

Follow accessibility guidelines.

Use plain language.

Explain before asking.

Prioritize safety over speed.

---

# Final Design Goal

Rakshak should feel like an Android application built by Google specifically to protect families from financial scams.

Users should never feel intimidated.

They should feel supported.