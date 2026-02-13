# Epic 4: Notifications & Launch

**Weeks:** 10–12  
**Phase:** Notification & Launch

---

## Objectives (from roadmap)

- **Notify at user local midnight:** Replicate Beepr-style utility without blasting everyone at 00:00 UTC.
- **OneSignal:** Use "Timezone Delivery" (deliver at 00:00 in user’s local time) to simplify backend; optional Celery "Midnight Cascade" if needed.
- **Client-side timer:** Flutter uses local timer for "Drop" moment; no server push required for UI unlock.
- **Listen handoff:** Notification opens app; server re-verifies `is_released()` for user timezone; then deep link to Spotify/Apple; auto-log Hype-to-Listen conversion.
- **Beta validation:** Verify Rolling Midnight across timezones; stress Ghost Entry reconciliation.

---

## Milestones

### M4.1 – OneSignal and timezone delivery (Week 10)

- Integrate OneSignal SDK in Flutter.
- Backend: send notifications with "deliver at 00:00 user local time" for release-day alerts; segments/tags by user timezone or tier (Stan / Fan / Casual).

### M4.2 – Unlock verification and Listen flow (Week 11)

- On "Listen" tap: server checks `is_released()` for user timezone before redirecting.
- Deep link to Spotify or Apple Music from app.
- Auto-log Hype-to-Listen conversion event for analytics.
- Optional: Celery Beat "Midnight Cascade" (e.g. pg_timezone_names) if not fully relying on OneSignal.

### M4.3 – Beta and validation (Week 12)

- Beta testing with users in multiple timezones.
- Verify Rolling Midnight behavior (countdown → unlock → review).
- Stress Ghost Entry reconciliation; harden error handling.

---

## User stories

- As a **Stan**, I want a push at midnight my time when a release drops so that I don’t miss it.
- As a **Fan**, I want a passive "New Release" notification so that I’m informed without being interrupted.
- As a **user**, I want the app to open and then send me to Spotify/Apple when I tap the notification so that I can listen immediately.
- As the **app**, I want to record when a hyped release leads to a "Listen" so that we can measure engagement.
- As the **app**, I want to re-verify release state when the user taps "Listen" so that clock manipulation doesn’t allow early access.
