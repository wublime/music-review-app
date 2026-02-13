# Epic 1: UI Foundation & Interface State Architecture

**Weeks:** 1–3  
**Phase:** Foundation & Design

---

## Objectives (from roadmap)

- **UI-First methodology:** Define data requirements through the user interface; resolve Rolling Midnight and state management at the interface level before committing backend work.
- **Hype Dashboard:** Dynamic, tiered dashboard that creates urgency and communal anticipation without "doom scrolling."
- **Rolling Midnight state machine:** ReleaseCard states (Locked → Drop → Unlocked) driven by local system time; countdown, unlock celebration, then review mode.
- **Tiered Hype:** Let users choose notification granularity (Stan / Fan / Casual) when following or hyping.
- **Log vs. Review:** Quick Log (low friction) vs. Deep Review (rating, body, listen date, backdating).
- **Ghost Entry:** When search fails, allow paste-a-link to create a temporary entry; optimistic UI, async reconciliation.
- **Frontend choice:** Flutter for animations (confetti, countdown), list performance, and cross-platform consistency.

---

## Milestones

### M1.1 – Hype Dashboard and countdown (Week 1)

- ReleaseCard widget with countdown timer (DD:HH:MM:SS).
- Locked state visuals: desaturated or overlaid artwork, emphasis on unavailability.
- "Hype This" action (boolean toggle or increment); local state for release state (no server dependency yet).
- Data requirement: `target_release_date` relative to user timezone for countdown.

### M1.2 – Tiered Hype and review flows (Week 2)

- Tiered Subscription Modal (Stan / Fan / Casual) when user follows an artist or hypes a release.
- Quick Log: swipe or long-press on album art; capture timestamp, user, release (mirrors "Watched" in Letterboxd).
- Deep Review: tap "Review" → modal with 10-point rating, review body, listen date picker (default "Now", backdating supported), tags.

### M1.3 – Rolling Midnight UX and Ghost Entry (Week 3)

- State transitions: Locked → Drop (confetti/unlock animation) → Unlocked; transition driven by client-side timer at release timestamp.
- "Listen" button in Drop/Unlocked: deep link to Spotify or Apple Music.
- Unlocked state: replace countdown with social proof (e.g. average rating, friend activity, global hype count).
- Ghost Entry: on search failure, show "Not found? Paste a link"; paste Spotify/Apple link → scrape OpenGraph (title, artist, image) → create temporary local entry; user can rate, review, log immediately; flag for backend reconciliation.

---

## User stories

- As a **fan**, I want a countdown for upcoming releases so that I see when they drop in my timezone.
- As a **fan**, I want to "Hype This" without writing a review so that I can show anticipation easily.
- As a **fan**, I want the card to unlock and celebrate when it’s release day so that the moment feels special.
- As a **fan**, I want to choose my hype tier (Stan / Fan / Casual) so that I control how often I’m notified.
- As a **listener**, I want to log that I listened without rating so that I keep a diary without friction.
- As a **reviewer**, I want to give a 10-point rating and optional review with listen date so that I can backdate and be precise.
- As a **user**, I want to paste a link when search fails so that I can still log or review missing or exclusive releases.
