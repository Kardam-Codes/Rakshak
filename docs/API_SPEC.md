# API Specification

# Rakshak
### Your AI Companion for Safe Digital Banking

Version: 1.0
Status: Active

---

# Purpose

This document defines the REST API specification for Rakshak.

It serves as the contract between the Flutter frontend and the FastAPI backend.

Every endpoint, request, response, validation rule, and error format should follow this specification.

---

# API Design Principles

The API should be:

- Simple
- Predictable
- Versioned
- Secure
- Consistent
- Backward Compatible

---

# Base URL

Development

```
http://localhost:8000/api/v1
```

Production

```
https://api.rakshak.app/api/v1
```

---

# API Versioning

Current Version

```
v1
```

Future versions

```
/api/v2/

/api/v3/
```

Breaking changes require a new version.

---

# Authentication

Current Version

No authentication required.

Future Versions

Firebase Authentication

JWT Tokens

OAuth Support

---

# Content Type

All requests

```
Content-Type: application/json
```

All responses

```
application/json
```

---

# Standard Success Response

```json
{
    "success": true,
    "message": "Operation completed successfully.",
    "data": {}
}
```

---

# Standard Error Response

```json
{
    "success": false,
    "message": "Unable to process request.",
    "error": {
        "code": "INVALID_REQUEST",
        "details": null
    }
}
```

---

# HTTP Status Codes

| Code | Meaning |
|-------|----------|
|200|Success|
|201|Created|
|400|Bad Request|
|401|Unauthorized|
|403|Forbidden|
|404|Not Found|
|409|Conflict|
|422|Validation Failed|
|429|Too Many Requests|
|500|Internal Server Error|

---

# AI Analysis API

## Analyze Notification

### Endpoint

```
POST /analyze/notification
```

---

### Description

Analyzes financial notifications for scam risk.

---

### Request

```json
{
    "title": "Bank Alert",
    "content": "Click this link immediately.",
    "source": "WhatsApp",
    "language": "en"
}
```

---

### Response

```json
{
    "success": true,
    "message": "Analysis completed.",
    "data": {
        "riskLevel": "High",
        "confidence": 0.96,
        "explanation": "The notification contains urgency and an unknown link.",
        "recommendedAction": "Do not open the link."
    }
}
```

---

## Analyze URL

### Endpoint

```
POST /analyze/url
```

---

### Request

```json
{
    "url": "https://example.com"
}
```

---

### Response

```json
{
    "success": true,
    "data": {
        "riskLevel": "Low",
        "confidence": 0.89,
        "explanation": "No suspicious indicators detected."
    }
}
```

---

## Analyze QR Code

### Endpoint

```
POST /analyze/qr
```

---

### Request

```json
{
    "qrContent": "upi://pay?..."
}
```

---

### Response

```json
{
    "success": true,
    "data": {
        "riskLevel": "Medium",
        "explanation": "Verify the merchant before payment."
    }
}
```

---

## Analyze Screenshot

### Endpoint

```
POST /analyze/image
```

---

### Description

Extracts text from screenshots or images and performs scam analysis.

---

### Request

```
multipart/form-data
```

Field

```
image
```

---

### Response

```json
{
    "success": true,
    "data": {
        "riskLevel": "High",
        "confidence": 0.94,
        "detectedText": "...",
        "explanation": "Possible refund scam detected."
    }
}
```

---

# Alert APIs

## Get Alert History

### Endpoint

```
GET /alerts
```

---

### Response

```json
{
    "success": true,
    "data": [
        {}
    ]
}
```

---

## Get Alert

### Endpoint

```
GET /alerts/{id}
```

---

## Delete Alert

### Endpoint

```
DELETE /alerts/{id}
```

---

## Delete All Alerts

### Endpoint

```
DELETE /alerts
```

---

# Scan History APIs

## Get Scan History

```
GET /scan-history
```

---

## Delete Scan

```
DELETE /scan-history/{id}
```

---

## Clear Scan History

```
DELETE /scan-history
```

---

# Trusted Family APIs

## Get Contacts

```
GET /trusted-contacts
```

---

## Add Contact

```
POST /trusted-contacts
```

Request

```json
{
    "name": "John",
    "phoneNumber": "+911234567890",
    "relationship": "Brother"
}
```

---

## Update Contact

```
PUT /trusted-contacts/{id}
```

---

## Delete Contact

```
DELETE /trusted-contacts/{id}
```

---

# Settings APIs

## Get Settings

```
GET /settings
```

---

## Update Settings

```
PUT /settings
```

Example

```json
{
    "language": "gu",
    "voiceEnabled": true,
    "darkMode": false
}
```

---

# Permission APIs

## Get Permission Status

```
GET /permissions
```

---

## Update Permission

```
PUT /permissions
```

---

# Recovery APIs

## Save Recovery Action

```
POST /recovery-actions
```

---

## Get Recovery History

```
GET /recovery-actions
```

---

# Health Check

```
GET /health
```

Response

```json
{
    "status": "healthy"
}
```

---

# Validation Rules

Notification content

Maximum

5000 characters

---

URLs

Must be valid HTTP or HTTPS URLs.

---

Phone numbers

Must follow E.164 format.

Example

```
+911234567890
```

---

Language

Supported values

```
en

gu
```

---

# Error Codes

| Code | Description |
|-------|-------------|
|INVALID_REQUEST|Malformed request|
|VALIDATION_ERROR|Input validation failed|
|NOT_FOUND|Resource not found|
|UNAUTHORIZED|Authentication required|
|FORBIDDEN|Access denied|
|RATE_LIMITED|Too many requests|
|AI_SERVICE_UNAVAILABLE|AI service unavailable|
|DATABASE_ERROR|Database operation failed|
|INTERNAL_SERVER_ERROR|Unexpected server error|

---

# Rate Limiting

Current Version

Not enforced.

Future

100 requests per minute per device.

---

# Security

Never transmit

- OTP
- UPI PIN
- Password
- CVV
- Banking credentials

All communication should use HTTPS in production.

Validate every incoming request.

---

# Future APIs

Reserved endpoints

```
/government-advisories

/community-reports

/merchant-reputation

/financial-safety-score

/voice-assistant

/scam-trends
```

---

# API Development Guidelines

Every endpoint should:

- Validate input
- Return consistent responses
- Handle errors gracefully
- Include meaningful messages
- Log failures
- Avoid exposing internal implementation details

---

# Summary

The Rakshak API is designed as a versioned, RESTful interface that provides consistent, secure, and scalable communication between the Flutter frontend and FastAPI backend. It follows standardized request and response formats, clear validation rules, and modular endpoint organization to support current functionality while remaining extensible for future releases.