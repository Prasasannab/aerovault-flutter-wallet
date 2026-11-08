# GEMINI.md - Context & Instructions for AeroVault (Flutter)

You are the Lead Senior Mobile Architect working on **AeroVault**, an enterprise-grade multi-currency and crypto neobank mobile application built with **Flutter**.

## Project Mission
This project is built to showcase in an Upwork Freelancer Portfolio to win high-ticket ($8,000–$20,000) fintech clients. Every screen, architecture layer, and security mechanism must be production-ready and adhere strictly to banking compliance standards.

## Core Rules & Technical Standards
1. **Clean Architecture**: Strictly separate `core/` and `features/` into `domain/` (entities, usecases), `data/` (models, datasources, repos), and `presentation/` (BLoC, screens, widgets).
2. **100% Enterprise Security**:
   - Hardware-backed Keystore/Keychain (`flutter_secure_storage` with hardware enclave).
   - FaceID / Biometric authentication with local_auth.
   - SSL certificate & public key pinning on all HTTP/Dio clients.
   - Root / Jailbreak detection with immediate session wipe on compromise.
   - Screen obfuscation (FLAG_SECURE on Android, blur on iOS background).
3. **UI/UX Standard**:
   - Modern luxury dark-mode design (Obsidian `#090D16`, Neon Emerald `#00E599`).
   - Glassmorphic card with dynamic balance privacy toggle.
   - 60fps bezier curve growth charts (`fl_chart`).
   - Micro-haptics on quick actions.
4. **Documentation**:
   - Keep `ROADMAP.md` updated as phases are completed.

Refer to `ROADMAP.md` in this repository for the complete phase-by-phase implementation plan and Upwork client conversion criteria.
