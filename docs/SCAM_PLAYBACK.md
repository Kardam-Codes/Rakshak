# Scam Playbook

# Rakshak
### Your AI Companion for Safe Digital Banking

Version: 1.0
Status: Active

---

# Purpose

This document serves as the central knowledge base for all financial scams recognized by Rakshak.

It defines:

- Scam categories
- Scam behavior
- Detection indicators
- User risks
- AI reasoning hints
- Recommended user actions

This document should evolve continuously as new scam techniques emerge.

---

# Scam Detection Philosophy

Rakshak does not attempt to detect every suspicious message.

Rakshak focuses on detecting scams that can cause financial loss.

Priority is given to scams that:

- Steal money
- Steal banking credentials
- Steal OTPs
- Trick users into making payments
- Install malicious applications
- Manipulate users through fear or urgency

---

# Scam Severity Levels

## Critical

Immediate financial loss possible.

Requires instant user attention.

Examples

- UPI Collect Request
- OTP Theft
- Remote Access App Scam

---

## High

Strong indicators of fraud.

Examples

- Fake Bank Message
- Fake Refund
- QR Payment Scam

---

## Medium

Potential fraud requiring verification.

Examples

- Investment Offer
- Unknown Loan Offer
- Cashback Offer

---

## Low

Suspicious but limited financial impact.

Examples

- Promotional spam
- Unknown advertisements

---

# Scam Categories

Rakshak currently supports the following scam categories.

---

# 1. Phishing Scam

## Description

Attempts to steal personal or banking information through fake websites or messages.

---

## Common Indicators

- Unknown links
- Misspelled domains
- Fake login pages
- Fake banking websites
- Urgent account verification

---

## Example

```
Your SBI account will be suspended.

Verify immediately:

http://sbi-secure-login.xyz
```

---

## Detection Hints

- Unknown domain
- Banking keywords
- Urgency language
- Login request

---

## Recommended Action

- Do not click the link.
- Visit the official website manually.
- Contact the bank if unsure.

---

# 2. Fake UPI Collect Request

## Description

The scammer sends a request asking the user to approve a payment instead of receiving money.

---

## Common Indicators

- "Accept to receive money."
- Unexpected payment request
- Unknown sender

---

## Example

```
Accept this request to receive $250 cashback.
```

---

## Detection Hints

- Collect Request
- Unknown merchant
- Reward language

---

## Recommended Action

- Reject the request.
- Verify the sender.
- Never approve unexpected requests.

---

# 3. QR Code Scam

## Description

The victim scans a QR code believing money will be received.

Instead, the QR initiates a payment.

---

## Indicators

- QR shared through chat
- Cashback claim
- Refund claim
- Prize claim

---

## Example

```
Scan this QR to receive your refund.
```

---

## Recommended Action

- Never scan unknown payment QR codes.
- Verify the sender first.

---

# 4. OTP Theft

## Description

The scammer requests the OTP to complete unauthorized transactions.

---

## Indicators

- Requests OTP
- Fake customer support
- Fake bank executive

---

## Example

```
Please tell me the OTP to verify your account.
```

---

## Detection Hints

- OTP keyword
- Verification request
- Unknown caller

---

## Recommended Action

Never share OTP with anyone.

Banks never ask for OTP over calls or messages.

---

# 5. Fake KYC Update

## Description

The victim is told that KYC has expired.

---

## Indicators

- KYC expired
- Update immediately
- Account blocked

---

## Example

```
Complete KYC today or your account will be blocked.
```

---

## Recommended Action

Update KYC only through official banking channels.

---

# 6. Fake Loan Scam

## Description

Promises instant loans with advance processing fees.

---

## Indicators

- Instant approval
- No documents
- Processing fee
- Registration fee

---

## Example

```
Get an instant $6,000 loan.

Pay only $15 processing fee.
```

---

## Recommended Action

Never pay advance fees for loans.

---

# 7. Fake Refund Scam

## Description

Claims money will be refunded after accepting a payment request.

---

## Indicators

- Refund
- Cashback
- Accept request
- Scan QR

---

## Example

```
Accept this payment request to receive your refund.
```

---

## Recommended Action

Refunds never require sending money.

---

# 8. Lottery Scam

## Description

Claims the user has won money or prizes.

---

## Indicators

- Lucky winner
- Prize
- Jackpot
- Reward
- Claim immediately

---

## Example

```
Congratulations!

You won $10,000.
```

---

## Recommended Action

Ignore.

Verify only through official organizations.

---

# 9. Investment Scam

## Description

Promises guaranteed returns with little or no risk.

---

## Indicators

- Double your money
- Guaranteed profit
- Limited investment opportunity
- Crypto profit
- Trading signal

---

## Recommended Action

No investment is guaranteed.

Research independently before investing.

---

# 10. Job Scam

## Description

Offers fake jobs that require registration or processing fees.

---

## Indicators

- Work from home
- Earn daily
- Registration fee
- Joining fee

---

## Recommended Action

Legitimate employers do not ask applicants to pay for jobs.

---

# 11. Screen Sharing Scam

## Description

The scammer convinces the victim to install a remote access application.

---

## Indicators

- AnyDesk
- TeamViewer
- QuickSupport
- Remote access
- Screen sharing

---

## Recommended Action

Never install remote access apps for unknown callers.

---

# 12. Impersonation Scam

## Description

The scammer pretends to represent a trusted organization.

---

## Examples

- Bank
- RBI
- Police
- Cyber Cell
- Income Tax
- Government Department

---

## Indicators

- Official logo
- Fake identity
- Threat language

---

## Recommended Action

Verify independently using official contact details.

---

# Universal Red Flags

The following indicators increase scam probability.

- Urgency
- Fear
- Rewards
- Unknown links
- Unknown QR codes
- OTP requests
- PIN requests
- Payment requests
- Advance fee
- Threats
- Impersonation
- Poor grammar
- Misspelled domains
- Emotional manipulation

---

# Safe Financial Practices

Rakshak should encourage users to:

- Verify before paying.
- Never share OTP.
- Never share UPI PIN.
- Verify bank messages.
- Check URLs carefully.
- Contact banks using official numbers.
- Ask trusted family members if uncertain.

---

# AI Detection Keywords

Examples only.

Financial

- bank
- account
- debit
- credit
- UPI
- PIN
- OTP
- payment

Urgency

- immediately
- today
- urgent
- now
- suspended

Reward

- cashback
- refund
- winner
- prize
- bonus

Threat

- blocked
- legal action
- suspend
- penalty
- freeze

---

# Explainability Guidelines

Every detection should explain:

- What was found
- Why it matters
- What could happen
- What the safest action is

Never display only a risk score.

---

# Future Scam Categories

Reserved for future versions.

- AI Voice Clone Scam
- Deepfake Video Scam
- Fake Investment Apps
- Fake Government Subsidy Scam
- SIM Swap Scam
- Digital Arrest Scam
- Social Media Marketplace Scam
- Fake Charity Scam
- Fake Courier Scam
- Cryptocurrency Wallet Scam

---

# Continuous Updates

The Scam Playbook should be reviewed regularly.

New scam techniques should be:

- Categorized
- Documented
- Assigned a severity
- Added to AI prompts
- Added to Rule Engine keywords
- Included in testing datasets

---

# Summary

The Scam Playbook is Rakshak's living fraud intelligence repository. It standardizes how scams are categorized, detected, explained, and handled, ensuring that both the Rule Engine and AI system provide consistent, explainable, and user-focused financial protection while remaining adaptable to emerging fraud techniques.