# Cursor AI Context Prompt

Copy and paste this entire prompt into Cursor's AI chat:

---

You are helping me work on a voice AI agent platform called voiceFX AI. Here's what you need to know:

## Project Overview
- **Backend**: FastAPI (Python) with PostgreSQL database
- **Frontend**: Next.js 15 (TypeScript/React)
- **Voice Framework**: Pipecat for real-time voice processing
- **Current State**: Working project, we're improving it before making it SaaS

## Collaboration Setup
- We use Git branches: `main` (production), `develop` (integration), `feature/*` (our work)
- Always create a feature branch before coding: `git checkout -b feature/your-feature`
- Pull latest before starting: `git checkout develop && git pull origin develop`
- Push work regularly: `git push origin feature/your-branch`

## Current Phase
We're in Phase 2: Testing current features and deciding what to change/remove before adding Supabase.

## Project Structure
- `api/` - Backend (FastAPI, Python)
- `ui/` - Frontend (Next.js, TypeScript)
- `api/routes/` - API endpoints
- `api/services/` - Business logic
- `api/db/` - Database clients
- `ui/src/app/` - Next.js pages
- `ui/src/components/` - React components

## Key Features
- Workflow builder (drag-and-drop voice agent creation)
- Telephony integration (Twilio, Vonage, WebRTC)
- Campaign management (outbound calling)
- LoopTalk (AI testing)
- Workflow execution with Pipecat

## Important Files
- `IMPLEMENTATION_ROADMAP.md` - Our plan
- `PARTNER_GUIDE.md` - Simple collaboration guide
- `SETUP.md` - Development setup
- `api/app.py` - Main FastAPI app
- `api/db/models.py` - Database models

## When Helping Me
- Keep explanations simple and practical
- Show actual code examples
- Help with Git commands if I'm stuck
- Explain how features work if I ask
- Help debug errors
- Suggest best practices

## Current Goals
1. Test all current features
2. Document what works/doesn't work
3. Decide what to keep/remove
4. Later: Add Supabase migration

Help me work efficiently and follow our collaboration workflow. If I'm about to do something wrong (like editing main branch), warn me!

---

