# Rakshak - Project Context & Hackathon Dossier

## 1. Project Overview
**Rakshak** is a sophisticated, real-time cyber-security and fraud-prevention application designed to protect digitally vulnerable users (such as the elderly and new smartphone users) from highly coordinated cyber scams. Rakshak sits quietly in the background of the user's Android phone, intercepting and neutralizing digital threats autonomously. 

Unlike traditional cloud-based security apps that upload your screen data and private calls to servers, Rakshak is built on a **100% Zero-Knowledge Offline Architecture**. All analysis is mapped natively on the user's physical device hardware—meaning no personal data ever leaves the phone. 

### Core Threats Mitigated:
*   **UPI Scams:** Fake cashback and fraudulent collection links targeting Indian payment infrastructure.
*   **OTP Theft:** Intercepts attempts by hackers trying to scrape One-Time Passwords via screen-share apps or forwarding tricks.
*   **Social Engineering/Job Scams:** Catches impersonators offering fake part-time work or crypto tasks.
*   **Malicious Calls:** Actively transcribes call audio locally and terminates connections from known spam grids.
*   **Malicious QR Codes & Links:** Sandboxes QR payloads before the system browser resolves them.

---

## 2. Technical Architecture

### Tech Stack:
*   **Frontend Ecosystem:** Flutter (Dart), leveraging `flutter_riverpod` for dependency injection and State Management.
*   **Local Database:** Hive (A NoSQL, AES-encrypted embedded database) managing history and settings.
*   **Machine Learning (SLM):** MediaPipe GenAI. Rakshak bundles a massive **1.3GB Gemma-2b-it-gpu-int4** offline LLM model natively into the Android runtime layout. 
*   **System Listeners:** Android standard `NotificationListenerService` hooks and hardware telephony bridging.

### Zero-Knowledge Pipeline:
Before any text (such as a call transcript or a parsed SMS) is fed into the AI, it passes through the `PIIMasking` engine.
*   Regex strictly scrubs Aadhar numbers, Phone Numbers, PAN cards, inside the Dart isolate.
*   Variables are swapped for structural placeholders (`[PHONE_REDACTED]`).
*   Only scrubbed, anonymous conversational context is mapped to the Neural Network inference timeline. 

---

## 3. Key Modules & Features

### 1. The Offline Explainability Engine (`offline_ai_engine.dart`)
When the master rule-engine detects a threat, Rakshak uses its 1.3GB embedded Gemma model to generate a custom, easy-to-read "2-sentence safety explanation" natively on the phone. Because generating text is notoriously resource-heavy (and standard Android Emulators suffer massive thermal CPU throttling), we engineered a **Completer-based Asynchronous Mutex Lock**. This prevents native C++ MediaPipe crashes if two scams hit at the exact same millisecond, and queues them perfectly in the Dart Isolated Event Loop with a 60-second hardware timeout threshold.

### 2. High-Risk OTP Isolation (`otp_rules.dart`)
If Rakshak detects a One-Time Password notification, it instantly cross-references it with keywords like "forward" or "share". If an active screen-share overlay is detected, Rakshak deploys a massive standard Android Heads-up override, physically restricting users from reading or copying the OTP to their clipboard until they acknowledge the security threat. 

### 3. Trusted Family Network (`trusted_family_service.dart`)
Users can configure SOS contacts natively. 
*   **The Problem:** If a user receives 10 spam texts in one minute, their family members' phones will get blasted with 10 emergency SOS texts, leading to panic and API rate-limiting.
*   **The Solution:** We implemented an extremely efficient **30-Minute Dispatch Debouncer** mapping the Scam Category `DateTime` signatures in memory. 
*   **Local Cancellation Intercept:** We wired a native **"Dismiss/Cancel Alert"** action directly into the Android notification tray. If a user recognizes a false positive, tapping "Cancel" instantly communicates back into the Dart Background Thread, aborting the asynchronous background timer, gracefully stopping the emergency dispatch.

### 4. Background Audio Daemon (`offline_audio_buffer.dart` & Whisper)
Rakshak maintains a rolling physical 30-second ephemeral buffer of raw call audio. This acts like a dashcam for phone conversations. If legacy NLP scripts flag dangerous financial pressure (e.g. "sir download app now"), the offline NPU slices the last 30 seconds of context and asks the Gemma LLM if it constitutes social engineering.

---

## 4. Hackathon Q&A Strategy Guidelines

If your teammate needs to script a Q&A or Pitch regarding the engineering:

**Q: How do you guarantee absolute user privacy?**
**A:** "We deployed a Zero-Knowledge Offline Pipeline. Rakshak possesses a 1.3GB physical AI module directly packed into the app. We severed all network bindings to our backend API endpoints. Any call audio or notification text is scrubbed via local Regex masks and analyzed solely on your mobile CPU/NPU. Your data literally never traverses the physical network bounds of your phone."

**Q: How do you optimize mobile AI which is usually heavy on the battery?**
**A:** "We enforce a hybridized fast-path cascade. We don't blast the GPU on every single notification. A lightweight rule-based heuristic scanner (using regex) acts as a strict firewall. The heavy 1.3GB Gemma model is only forcefully awakened when the fast-path parser identifies highly suspicious anomaly tokens. By combining an asynchronous Mutex execution lock with standard caching, we maintain zero runtime UI-thread blockage."

**Q: In a real-world scenario, what happens if an elderly user is about to send money to a scammer on a phone call?**
**A:** "Rakshak's background daemon seamlessly slices the live conversation transcript. Our SLM analyzes the coercion context. Simultaneously, a Heads-Up local Android Notification physically overrides their screen containing a custom AI explanation ("This person is requesting you to download a desktop sharing app"). Meanwhile, a silent 10-second background countdown triggers. If they don't explicitly cancel the alert, Rakshak natively executes hardware SMS modules invoking a WhatsApp alert API to explicitly ping their son or daughter that their parent is actively being manipulated."

---



*End of Context Document.*
