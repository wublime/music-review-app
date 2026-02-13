# Epic Plans — Unified Music Lifecycle Platform

These plans implement the [Architectural Blueprint (roadmap)](../../roadmap.md) for the platform: **Hype (Pre-release) → Listen (Release Day) → Review (Post-release)**. Each epic maps to a phase of the 12-week execution roadmap.

## Epic index

| Epic | Name | File | Weeks | Objective |
|------|------|------|-------|------------|
| 1 | UI Foundation & Interface State | [epic1-ui-foundation.md](epic1-ui-foundation.md) | 1–3 | Hype Dashboard, Rolling Midnight UI, Tiered Hype, Log/Review, Ghost Entry |
| 2 | Backend Core & Data Model | [epic2-backend-core.md](epic2-backend-core.md) | 4–6 | FastAPI, PostgreSQL schema, release state, dashboard/review APIs |
| 3 | Data Integration Pipeline | [epic3-data-integration.md](epic3-data-integration.md) | 7–9 | MusicBrainz, Apple Music, Spotify, Genius, lazy load, linking |
| 4 | Notifications & Launch | [epic4-notifications.md](epic4-notifications.md) | 10–12 | OneSignal, timezone delivery, Listen handoff, beta |

## Week mapping

- **Weeks 1–3:** Epic 1 — Foundation & Design (Flutter UI, state machine, review flows)
- **Weeks 4–6:** Epic 2 — Backend Core (FastAPI, DB schema, internal APIs)
- **Weeks 7–9:** Epic 3 — Data Pipeline (API integrations, lazy loading, linking)
- **Weeks 10–12:** Epic 4 — Notification & Launch (OneSignal, verification, beta)
