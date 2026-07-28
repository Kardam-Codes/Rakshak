# 🛡️ Rakshak

### Your AI Companion for Safe Digital Banking

> **Protecting first-time digital banking users from financial scams through explainable AI, real-time detection, multilingual guidance, and guided recovery.**

---

## 🚀 Overview

Rakshak is an AI-powered Android application designed to help users detect, understand, and avoid digital financial scams before money is lost.

Unlike traditional security applications, Rakshak focuses specifically on **financial fraud prevention** by combining lightweight on-device detection with explainable AI.

Rakshak protects users **before**, **during**, and **after** scam attempts by providing:

- 🔔 Real-time scam detection
- 🧠 Explainable AI analysis
- 💳 Smart UPI protection
- 📞 Scam call guidance
- 📷 QR & URL safety scanning
- 👨‍👩‍👧 Trusted Family Mode
- 🚨 Emergency Recovery Assistant
- 🌐 Multilingual support

---

# ✨ Key Features

## 🧠 AI Scam Guardian

Detects suspicious financial notifications from supported apps and explains why they are risky.

---

## 📞 Scam Call Guardian

Warns users during suspicious calls and provides post-call recovery guidance.

---

## 💳 Smart UPI Protection

Helps users understand payment requests, QR codes, and refund scams before approving transactions.

---

## 📷 Safe Scan

Analyze

- QR Codes
- URLs
- Screenshots
- Images

through one unified scanner.

---

## 🚨 Emergency Recovery

Provides guided recovery by helping users:

- Block suspicious numbers
- Contact their bank
- Report cybercrime
- Notify trusted contacts
- Save evidence

---

## 👨‍👩‍👧 Trusted Family Mode

Allows trusted family members to receive alerts during high-risk scam incidents.

---

# 🎯 Mission

To make digital banking safer, simpler, and more trustworthy for everyone—especially first-time digital banking users.

---

# 🏗️ System Architecture

```
                Flutter App
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ▼             ▼             ▼
 Notification    Scanner      Call Guardian
     Engine       Engine          Engine
        │             │             │
        └─────────────┼─────────────┘
                      ▼
              AI Risk Engine
              Rule Engine
                      │
                      ▼
         Explainability Engine
                      │
                      ▼
              Alert Manager
                      │
                      ▼
                    User
```

For detailed engineering documentation, see:

- `docs/SYSTEM_DESIGN.md`
- `docs/ARCHITECTURE.md`

---

# 🛠️ Technology Stack

## Frontend

- Flutter

## Backend

- FastAPI

## Database

- SQLite

## AI

- Google Gemini API
- Rule-Based Detection Engine

## Platform

- Android

---

# 📁 Repository Structure

```
Rakshak/

├── assets/
├── backend/
├── docs/
├── frontend/
├── scripts/
├── shared/

├── README.md
├── LICENSE
└── .env.example
```

---

# 📚 Documentation

## Product

- PRD.md
- FEATURE_LIST.md
- USER_FLOW.md
- ROADMAP.md

---

## Design

- DESIGN.md

---

## Engineering

- SYSTEM_DESIGN.md
- ARCHITECTURE.md
- DATABASE_SCHEMA.md
- API_SPEC.md

---

## Artificial Intelligence

- AI_RULES.md
- SCAM_PLAYBOOK.md

---

## Development

- CODING_STANDARDS.md
- TESTING_STRATEGY.md
- CONTRIBUTING.md

---

## Coming Soon

- THREAT_MODEL.md
- PROMPT_LIBRARY.md
- DECISION_LOG.md
- DEPLOYMENT.md

---

# 🚀 Getting Started

## Clone Repository

```bash
git clone https://github.com/<your-username>/Rakshak.git

cd Rakshak
```

---

## Frontend

```bash
cd frontend

flutter pub get

flutter run
```

---

## Backend

```bash
cd backend

python -m venv .venv
```

Windows

```cmd
.venv\Scripts\activate
```

Linux / macOS

```bash
source .venv/bin/activate
```

Install dependencies

```bash
pip install -r requirements.txt
```

Run server

```bash
uvicorn app.main:app --reload
```

---

# 🔒 Privacy First

Rakshak is designed around privacy.

The application:

- Performs lightweight analysis locally whenever possible.
- Sends only the minimum required data for advanced AI analysis.
- Never stores OTPs.
- Never stores passwords.
- Never stores UPI PINs.
- Never stores banking credentials.

---

# 🌍 Supported Languages

Current

- 🇬🇧 English
- 🇮🇳 Gujarati

Planned

- Hindi
- Marathi
- Tamil
- Telugu

---

# 🧪 Testing

Rakshak follows a layered testing strategy including:

- Unit Testing
- Widget Testing
- Integration Testing
- AI Evaluation
- Performance Testing
- Security Testing
- Accessibility Testing

See:

```
docs/TESTING_STRATEGY.md
```

---

# 🤝 Contributing

We welcome contributions.

Please read

```
docs/CONTRIBUTING.md
```

before opening an issue or Pull Request.

---

# 📈 Roadmap

The planned evolution of Rakshak is documented in

```
docs/ROADMAP.md
```

Upcoming areas include:

- Government scam advisories
- AI Voice Assistant
- Merchant reputation
- Community scam reports
- Regional language expansion

---

# 📄 License

This project is licensed under the terms of the project's LICENSE file.

---

# 🙏 Acknowledgements

Rakshak is inspired by the mission of making digital financial services safer and more accessible for everyone.

Special thanks to the open-source community and the tools that make this project possible.

---

# 📬 Contact

For questions, suggestions, or collaboration, please open an issue or start a discussion in this repository.

---

## ⭐ Support the Project

If you find Rakshak useful, consider:

- ⭐ Starring the repository
- 🐞 Reporting bugs
- 💡 Suggesting features
- 🤝 Contributing improvements

Together, we can make digital banking safer for everyone.
