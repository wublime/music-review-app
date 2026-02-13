# Epic 2: Backend Core & Data Model

**Weeks:** 4–6  
**Phase:** Backend Core

---

## Objectives (from roadmap)

- **FastAPI:** Async support for I/O-bound work (APIs, notifications); Pydantic for validation of external music data; low latency for JSON endpoints.
- **PostgreSQL:** Relational schema for releases, artists, users, and subscriptions.
- **Release Group vs Release:** MusicBrainz-style split—Release Group = abstract album (reviews, hype); Release = concrete product (release date, streaming IDs, Rolling Midnight).
- **User timezone:** IANA timezone string (e.g. `America/New_York`) for correct midnight calculations; avoid offset-only storage due to DST.
- **Rolling Midnight logic:** Server-side `get_release_state(release_utc, user_timezone_str)` returning HYPE / DROP / OUT.
- **HypeSubscription:** Many-to-many table (user, release_group, tier, notification_sent) to power dashboard and notifications.

---

## Milestones

### M2.1 – Project and User model (Week 4)

- Initialize FastAPI project with PostgreSQL connection.
- User model with IANA timezone column (string); validate with Pydantic (e.g. timezone name / zoneinfo).

### M2.2 – MusicBrainz-style schema and release state (Week 5)

- **ReleaseGroup:** UUID, Title, Primary_Artist_ID, First_Release_Date, Release_Type (Album, EP, Single).
- **Release:** UUID, Release_Group_ID (FK), Release_Date, Country_Code, Barcode, Spotify_ID, Apple_Music_ID.
- **Artist:** UUID, Name, MusicBrainz_ID, Spotify_ID, Apple_Music_ID, Image_URL.
- Implement and test `get_release_state(release_utc, user_timezone_str)` (HYPE / DROP / OUT) using `zoneinfo`.

### M2.3 – API and subscriptions (Week 6)

- **HypeSubscription** table: id, user_id, release_group_id, tier (Stan / Fan / Casual), notification_sent (default False).
- Internal API: GET dashboard (releases + computed state per user), POST review, POST hype (subscribe).
- Pydantic request/response schemas for all endpoints.

---

## User stories

- As the **app**, I need the user’s timezone so that release state is correct for their location.
- As the **app**, I need Release Group vs Release so that reviews and hype are grouped and "Listen" uses the right streaming ID.
- As the **app**, I need server-side release state (HYPE / DROP / OUT) so that the UI and notifications are consistent.
- As a **user**, I want my hype dashboard to show releases in the right state so that I see countdown vs unlocked correctly.
- As a **user**, I want to submit a review (rating, body, date) so that it is stored and linked to the release group.
