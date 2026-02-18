# Epic 1: UI Foundation & Interface State Architecture

**Timeline:** Weeks 1–3  
**Project Phase:** Foundation & Design

---

## Objectives

* **UI-First Methodology:** Define data requirements through the user interface; resolve "Rolling Midnight" and state management at the interface level before committing to backend architecture.
* **Hype Dashboard:** Create a dynamic, tiered dashboard that drives urgency and communal anticipation without "doom scrolling."
* **Rolling Midnight State Machine:** Build ReleaseCard states (Locked → Drop → Unlocked) driven by local system time.
* **Tiered Hype:** Implement notification granularity selection (Stan / Fan / Casual) at the point of interaction.
* **Log vs. Review:** Balance "Quick Log" (low friction via FAB) with "Deep Review" (precise 10-point decimal rating and backdating).
* **Ghost Entry:** Develop an optimistic UI flow for search failures using link-pasting and async reconciliation.
* **Frontend Performance:** Utilize Flutter for high-fidelity animations (confetti, countdowns) and smooth list performance.

---

## Milestones

### M1.1 – Horizontal Hype & Dashboard (Week 1)
* [ ] **Horizontal Carousel:** Implement a `PageView` or horizontal `ListView` for the "Dropping This Week" section at the top of the home screen.
* [ ] **ReleaseCard Widget:** Build the core card component with a live countdown timer (DD:HH:MM:SS) positioned above the artwork per the UI sketch.
* [ ] **Locked State Visuals:** Create desaturated artwork overlays to communicate unavailability visually.
* [ ] **Mock Data Generation:** Create a local `mock_releases.json` file including fields for `like_count`, `comment_count`, and `share_count`.
* [ ] **Timezone Logic:** Implement `target_release_date` calculations relative to the user's local timezone for the countdown.

### M1.2 – Tiered Hype & Review Flows (Week 2)
* [ ] **Tiered Subscription Modal:** Build the UI for selecting "Stan," "Fan," or "Casual" tiers when a user hypes a release.
* [ ] **Floating Action Button (+):** Implement the central FAB as the primary trigger for the Quick Action menu.
* [ ] **Quick Log Flow:** Enable a 1-tap "Log" interaction (swipe/long-press) to capture timestamped consumption data instantly.
* [ ] **Deep Review Modal:** Build a modal supporting a **10-point scale with one decimal point (e.g., 9.8)**, text body, and a backdate-enabled date picker.

### M1.3 – Rolling Midnight UX & Ghost Entry (Week 3)
* [ ] **State Transitions:** Implement the logic for Locked → Drop (Animation) → Unlocked triggered by the client-side timer.
* [ ] **Dopamine Moment:** Integrate the `flutter_confetti` package to trigger automatically upon the countdown reaching zero.
* [ ] **Social Proof Feed:** Update the "Unlocked" state UI to replace the countdown with average ratings and friend activity.
* [ ] **Ghost Entry Pattern:** On search failure, implement the "Paste a link" flow to scrape OpenGraph tags for temporary local entry creation.

---

## User Stories

* **As a fan,** I want to see upcoming releases in a horizontal "Dropping This Week" carousel so I can quickly swipe through what's coming soon.
* **As a fan,** I want a countdown for upcoming releases so that I see when they drop in my specific timezone.
* **As a fan,** I want to "Hype This" without writing a full review so that I can show anticipation easily.
* **As a fan,** I want the card to unlock and celebrate with confetti when it hits midnight so that the release moment feels special.
* **As a fan,** I want to choose my hype tier (Stan / Fan / Casual) so that I can control my notification density.
* **As a listener,** I want to use the central (+) button to log that I listened without rating so that I keep a diary without friction.
* **As a reviewer,** I want to give a 10-point rating with one decimal point (e.g., 9.8/10) so I can be as precise as possible.
* **As a reviewer,** I want to be able to set my "Listen Date" to a past date if I'm catching up on my diary.
* **As a user,** I want to paste a link when search fails so that I can still log or review missing or exclusive releases.