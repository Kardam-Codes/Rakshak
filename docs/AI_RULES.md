# AI Rules

# Rakshak
### Your AI Companion for Safe Digital Banking

Version: 1.0
Status: Active

---

# Purpose

This document defines the Artificial Intelligence architecture, detection rules, prompt engineering guidelines, explainability standards, and fallback mechanisms used by Rakshak.

The goal is to ensure that every AI decision is:

- Explainable
- Consistent
- Safe
- Privacy-conscious
- Auditable

This document acts as the source of truth for all AI-powered features.

---

# AI Philosophy

Rakshak does not replace user judgment.

Instead, Rakshak acts as an intelligent assistant that:

- Detects suspicious financial activity
- Explains why it appears suspicious
- Suggests the safest next action

AI should never make irreversible decisions for the user.

---

# AI Responsibilities

The AI system is responsible for:

- Scam classification
- Risk scoring
- Natural language explanation
- Gujarati translation
- Safe recommendations
- Screenshot understanding
- QR interpretation
- URL reasoning
- UPI transaction explanation

The AI is **not** responsible for:

- Blocking transactions
- Sending payments
- Calling banks
- Automatically reporting crimes
- Taking destructive actions

---

# AI Pipeline

```
Incoming Event
        │
        ▼
Input Validation
        │
        ▼
Rule Engine
        │
        ▼
Needs AI?
    │         │
   No        Yes
    │         │
    ▼         ▼
 Local     Gemini Analysis
 Result        │
      └────────┘
           ▼
Risk Classification
           ▼
Explanation Engine
           ▼
Recommendation Engine
           ▼
User Alert
```

---

# AI Input Sources

The AI may receive data from:

- SMS
- WhatsApp Notifications
- Gmail Notifications
- UPI Notifications
- QR Codes
- URLs
- Screenshots
- Images
- Call Metadata
- User Feedback

---

# Rule Engine First

Every event must first pass through the local Rule Engine.

The Rule Engine is:

- Fast
- Offline
- Lightweight
- Explainable

All intercepted events flow unilaterally into the Native SLM.

---

# Rule Categories

The Rule Engine checks for:

## Urgency

Examples

- Immediate
- Act Now
- Limited Time
- Verify Today
- Account Suspended

---

## Financial Keywords

Examples

- OTP
- UPI
- Refund
- Cashback
- Bank
- Credit
- Debit
- PIN
- Account

---

## Suspicious Links

Examples

- URL Shorteners
- Unknown Domains
- Misspelled Domains
- Fake Banking URLs

---

## Fake Authority

Examples

- RBI
- Income Tax
- Police
- Cyber Cell
- Bank Manager

---

## Threat Language

Examples

- Freeze Account
- Legal Action
- Penalty
- KYC Failure

---

## Reward Language

Examples

- Prize
- Lottery
- Cashback
- Free Money
- Lucky Winner

---

# AI Classification Categories

Every analysis must classify content into one category.

Possible values

- Safe
- Informational
- Suspicious
- Scam
- Unknown

---

# Scam Categories

Supported scam types

- Phishing
- Fake UPI Collect Request
- QR Scam
- OTP Theft
- Fake Loan
- Fake KYC
- Investment Scam
- Refund Scam
- Lottery Scam
- Job Scam
- Screen Sharing Scam
- Impersonation
- Unknown

---

# Risk Levels

Four risk levels are used.

## Safe

Green

No immediate concern.

---

## Low

Monitor carefully.

---

## Medium

Exercise caution.

---

## High

Strong indicators of financial fraud.

Immediate user attention required.

---

# Confidence Score

AI returns a confidence score.

Range

```
0.00
↓

1.00
```

Example

```
0.97
```

Higher confidence indicates stronger evidence.

Confidence should never be shown without an explanation.

---

# Risk Calculation

Risk is determined using:

- Rule Engine Score
- AI Classification
- URL Reputation
- Keyword Analysis
- Context Analysis
- User Feedback

Final risk should combine all available signals.

---

# Explainability Requirements

Every AI response must answer:

1. What was detected?

2. Why is it suspicious?

3. What should the user do?

4. What should the user avoid?

Example

```
This message asks you to click an unknown link and verify your bank account.

Scammers often use similar messages to steal banking information.

Do not click the link.

Contact your bank using its official customer care number if you are unsure.
```

---

# Recommendation Types

Recommendations may include

- Ignore
- Verify Sender
- Do Not Click
- Do Not Pay
- Contact Bank
- Report Scam
- Block Number
- Ask Trusted Contact

Recommendations should always be actionable.

---

# Language Generation

Primary languages

- English
- Gujarati

Future versions

- Hindi
- Marathi
- Tamil
- Telugu

Translations should preserve meaning rather than perform literal translation.

---

# Prompt Engineering Principles

Prompts should:

- Be deterministic
- Avoid ambiguity
- Request structured output
- Minimize hallucinations
- Request explanations
- Avoid speculative answers

---

# Expected AI Output

Every response should contain

```json
{
  "riskLevel": "",
  "confidence": 0.95,
  "category": "",
  "explanation": "",
  "recommendedAction": "",
  "reasoning": []
}
```

---

# Example Reasoning

```json
[
  "Contains urgency language.",
  "Unknown banking link detected.",
  "Requests account verification."
]
```

---

# Screenshot Analysis

The AI should

- Extract text
- Detect banking brands
- Identify fake payment screenshots
- Identify suspicious URLs
- Detect fake receipts
- Detect fake refund messages

---

# QR Code Analysis

AI should determine whether the QR code

- Requests payment
- Opens a URL
- Contains UPI data
- Appears malformed
- Is potentially dangerous

Always explain whether scanning the QR will pay money or simply open information.

---

# URL Analysis

AI should evaluate

- Domain
- Brand similarity
- HTTPS usage
- Suspicious patterns
- URL shortening
- Known scam indicators

---

# Notification Analysis

AI evaluates

- Sender
- Message content
- Context
- Intent
- Financial terminology
- Threat language

---

# Call Analysis

The AI should never record calls.

Instead it may use

- Caller metadata
- User responses after the call
- Reported conversation details

---

# False Positive Handling

Users may mark alerts as

- Safe
- Incorrect
- Ignore

Future models may use anonymized feedback to improve accuracy.

---

# Privacy Rules

Never send

- OTP
- Password
- UPI PIN
- Card PIN
- CVV
- Aadhaar number
- Full bank account number

Sensitive information should be masked before AI processing whenever possible.

---

# Offline Behaviour

If internet is unavailable

- Use Rule Engine
- Generate local explanation
- Continue monitoring

Do not disable protection.

---

# AI Failure Handling

If Native Inference fails

- Retry once
- Fall back to Rule Engine
- Inform the user that advanced analysis is unavailable
- Continue providing basic protection

---

# Performance Targets

Rule Engine

Less than 100 ms

AI Request

Less than 3 seconds

Overall Alert Generation

Less than 4 seconds

---

# Continuous Improvement

Future improvements may include

- Better multilingual understanding
- Merchant reputation
- Community scam reports
- Government advisories
- Personalized scam detection

These improvements should not change the core AI workflow.

---

# AI Safety Principles

The AI must never:

- Invent facts
- Guess banking information
- Claim certainty without evidence
- Recommend unsafe actions
- Request personal financial information
- Encourage risky behavior

When uncertain, the AI should clearly state that confidence is limited and encourage the user to verify through official sources.

---

# Testing Requirements

Every AI feature should be evaluated using

- Known scam messages
- Legitimate banking messages
- Mixed-language content
- Gujarati notifications
- False-positive scenarios
- False-negative scenarios

Performance should be measured using

- Precision
- Recall
- False Positive Rate
- False Negative Rate
- Average Response Time

---

# Summary

Rakshak combines a lightweight local Rule Engine with a powerful Zero-Knowledge offline SLM to deliver explainable, privacy-conscious financial scam detection. Every decision must be transparent, actionable, and focused on helping users make safer financial choices while minimizing unnecessary AI usage and protecting sensitive personal information.