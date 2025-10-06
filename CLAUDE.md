# CLAUDE.md — Project Context for Captionary

## 🎯 Project Overview
**Name:** Captionary
**Purpose:** iOS app that generates AI-powered captions for photos/videos in 4 simple steps
**Stack:** SwiftUI + Supabase + OpenAI GPT-4o + Google Gemini
**Model:** Freemium subscription (Free / Premium / Pro)

---

## 📁 Repository Structure
```
Captionary/
├── captionary/                    # Xcode project
│   └── captionary/
│       ├── CaptionaryApp.swift   # App entry point
│       ├── Models/               # Data models
│       ├── ViewModels/           # Business logic
│       ├── Views/                # SwiftUI screens
│       ├── Services/             # API clients & managers
│       └── Resources/            # Assets & Secrets
├── Captionary_Docs/              # Product documentation
│   ├── 00_PRODUCT_BRIEF.md
│   ├── 01_TECH_STACK.md
│   ├── 02_SUPABASE_SCHEMA.md
│   ├── 03_IOS_APP_STRUCTURE.md
│   └── 04_LLM_PROMPTS.md
├── CLAUDE_RULES.md               # AI governance rules
├── CLAUDE_MCP.md                 # MCP server setup
└── CLAUDE.md                     # This file
```

---

## 🧩 Core Architecture

### Data Flow
1. **User Input:** Mood → Media → Goal → Style (4-step wizard)
2. **Vision Analysis:** Extract context from photo/video
3. **API Call:** Supabase Edge Function → OpenAI/Gemini
4. **Results:** 3 caption variants + hashtags + alt text + scores
5. **Storage:** Save to Supabase with usage counter updates

### Key Components
- **WizardVM:** Manages 4-step caption generation flow
- **SessionVM:** Auth state, subscription status, usage limits
- **PaywallVM:** StoreKit 2 subscription management
- **CaptionEngine:** Routes requests to OpenAI or Gemini based on cost
- **SupabaseClient:** Authentication & database operations

---

## 🛠 Tech Stack Summary
- **Frontend:** SwiftUI, Combine, PhotosUI, Vision, StoreKit 2
- **Backend:** Supabase (Auth, Postgres, Edge Functions, Storage)
- **AI:** OpenAI GPT-4o (quality) + Google Gemini (cost optimization)
- **CI/CD:** Xcode Cloud + TestFlight
- **Analytics:** Supabase events + Apple App Analytics

---

## 📋 Development Guidelines

### Code Style
- Follow Swift conventions (camelCase, PascalCase for types)
- Use `async/await` for concurrency
- Prefer structs over classes where possible
- Document complex business logic with inline comments

### Security
- Never commit `Secrets.plist` or API keys
- Use Supabase RLS for all database queries
- Validate all user inputs before API calls
- Follow Apple's App Store Review Guidelines

### Testing
- Write unit tests for ViewModels and Services
- Test subscription flows thoroughly
- Validate usage limit enforcement
- Test offline error handling

---

## 🚀 Development Workflow

### Branch Strategy
- `main` — production-ready code
- `feature/<name>` — new features
- `fix/<name>` — bug fixes
- `doc/<name>` — documentation updates

### Commit Messages
Use conventional commits:
- `feat:` new features
- `fix:` bug fixes
- `refactor:` code improvements
- `docs:` documentation changes
- `test:` test additions/changes

---

## 🔗 Key Documentation References

### Product
- [00_PRODUCT_BRIEF.md](Captionary_Docs/00_PRODUCT_BRIEF.md) — Core product vision
- [01_TECH_STACK.md](Captionary_Docs/01_TECH_STACK.md) — Technology decisions

### Backend
- [02_SUPABASE_SCHEMA.md](Captionary_Docs/02_SUPABASE_SCHEMA.md) — Database structure

### Frontend
- [03_IOS_APP_STRUCTURE.md](Captionary_Docs/03_IOS_APP_STRUCTURE.md) — iOS architecture
- [04_LLM_PROMPTS.md](Captionary_Docs/04_LLM_PROMPTS.md) — AI prompt templates

### Governance
- [CLAUDE_RULES.md](CLAUDE_RULES.md) — AI collaboration rules
- [CLAUDE_MCP.md](CLAUDE_MCP.md) — MCP server configuration

---

## 🎨 Design Principles
1. **Simplicity First:** 4 taps to great captions
2. **Minimal Typing:** Chip-based selection UI
3. **Context Aware:** Use Vision API to understand media
4. **Quality Focus:** Multiple variants with scoring
5. **Privacy Respectful:** No PII in AI requests

---

## 📞 Decision Escalation
When Claude encounters ambiguity:
1. **Pause** — Don't make assumptions
2. **Summarize** — Present 2-3 solution options
3. **Wait** — Get explicit human approval
4. **Document** — Record decision in commit message

---

## ✅ Current Status
- ✅ Documentation complete
- ✅ Xcode project created
- ✅ Git repository initialized
- 🔲 Folder structure pending
- 🔲 Core implementation pending
- 🔲 Supabase integration pending
- 🔲 StoreKit 2 integration pending

---

## 🤝 Collaboration Etiquette
- **`@claude suggest`** → Safe proposals, no changes
- **`@claude execute`** → Requires explicit confirmation
- **`@claude review`** → Code review and improvements
- **`@claude explain`** → Documentation and learning

---

**Last Updated:** 2025-10-06
**Project Phase:** Initial Setup
**Next Milestone:** Core app structure implementation
