# **Architectural Blueprint for the Unified Music Lifecycle Platform: From Hype to Review**

## **Executive Summary**

The digital music ecosystem is currently characterized by a functional schism. On one side, utility-centric applications like **Beepr** provide instantaneous, push-driven notifications for new releases, catering to the "hype" cycle of fandom. However, these platforms often suffer from notification fatigue and lack the community infrastructure to sustain engagement once the release moment has passed. On the other side, cataloging platforms like **Letterboxd**, **Musicboard**, and **Rate Your Music (RYM)** offer robust reviewing capabilities and historical archival but fail to capture the visceral anticipation of the pre-release window. They are retrospective rather than prospective.

This report outlines a comprehensive, 12-week architectural roadmap for a solo developer to bridge this gap. The proposed mobile application aims to own the full lifecycle of music fandom: **Hype (Pre-release) ![][image1] Listen (Release Day) ![][image1] Review (Post-release).**

Adopting a **"UI-First" methodology** is strategically vital for a solo developer learning Python. It forces the resolution of complex state management issues—specifically the "Rolling Midnight" release logic—at the interface level before backend resources are committed. This report prioritizes the construction of a resilient frontend state machine capable of handling the temporal complexities of global music releases, where an album is simultaneously "out now" in New Zealand and "coming soon" in New York.

The backend architecture leverages **Python (FastAPI)** for high-concurrency performance and **PostgreSQL** for robust relational data modeling, specifically addressing the limitations of relying solely on third-party APIs like Spotify, Apple Music, MusicBrainz, and Genius. By synthesizing the immediate utility of Beepr with the archival depth of Letterboxd, this platform addresses the friction points identified in current market solutions—specifically the "doom scrolling" of notification feeds and the rigid, mandatory rating systems of review apps.

## ---

**Phase 1: UI/UX Strategy and Interface State Architecture**

For a solo developer, the greatest risk is backend over-engineering. By strictly adhering to a UI-First methodology, we define the data requirements through the lens of the user interface. This phase focuses on designing the visual and interactive states that will govern the user's journey through the hype cycle. The interface must not only display data but also manage the user's emotional anticipation and transition from passive observer to active listener and critic.

### **1.1 The "Hype Dashboard": Visualizing Anticipation**

The core differentiator of this platform is the "Hype Dashboard." Unlike the static lists found in streaming services, this dashboard must be dynamic, creating a sense of urgency and communal anticipation. Competitor analysis of **Beepr** reveals that while users value the utility of notifications, they suffer from significant friction due to "doom scrolling" and clutter.1 The UI must solve this by organizing release data into a structured, tiered hierarchy.

#### **1.1.1 The "Rolling Midnight" State Machine**

The most complex UI challenge is the "Rolling Midnight" phenomenon. Music releases typically occur at 00:00 local time. This means a single database entity (an album) exists in different states for different users simultaneously. The UI must handle this relativity without querying the server for every second of the countdown.

The dashboard UI will consist of ReleaseCard widgets that operate on a strict internal state machine. This state machine dictates the available user actions and the visual presentation of the card.

**State 1: Locked (Hype Mode)**

* **Trigger:** The local system time is less than the release timestamp.  
* **Visuals:** The primary visual element is a **Countdown Timer** (DD:HH:MM:SS). The album artwork is potentially desaturated or overlaid with the timer to emphasize unavailability.  
* **User Action:** "Hype This." This is a lightweight interaction—a boolean toggle or increment—that creates a subscription record in the backend. It satisfies the user's need to express anticipation without requiring a text review.  
* **Data Requirement:** The UI needs a target\_release\_date calculated relative to the user's specific timezone.

**State 2: The Drop (Unlocking Transition)**

* **Trigger:** The local system time equals the release timestamp (![][image2]).  
* **Visuals:** This is the critical "dopamine moment." The UI must visually celebrate the transition. Implementing a confetti animation or a visual "unlocking" effect (e.g., the lock icon breaking, the artwork becoming fully saturated) mimics the excitement of a physical release.2  
* **User Action:** The primary action button transforms from "Hype" to "Listen." This button is a deep link that opens the specific album in the user's preferred streaming service (Spotify or Apple Music).  
* **Technical Constraint:** This transition must happen client-side. Relying on a server push to update the UI at midnight is prone to latency and network failure. The app must internally schedule this state change based on the system clock.

**State 3: Unlocked (Review Mode)**

* **Trigger:** The local system time is greater than the release timestamp.  
* **Visuals:** The countdown timer is removed entirely. It is replaced by social proof metrics: "Average Rating," "Friend Activity," or "Global Hype Count."  
* **User Action:** The primary action becomes "Log" or "Review." The interface shifts from anticipation to reflection.

#### **1.1.2 Mitigating Notification Fatigue via "Tiered Hype"**

Beepr reviews highlight a critical friction point: users feel overwhelmed by notifications for artists they only casually like, yet they fear missing out if they disable notifications entirely.1 To prevent the "doom scrolling" effect, the UI must allow users to define the granularity of their fandom *before* the backend logic is engaged.

The UI should implement a **Tiered Subscription Modal** whenever a user follows an artist or hypes a release:

| Tier | User Intent | UI Behavior | Notification Behavior |
| :---- | :---- | :---- | :---- |
| **Tier 1: Stan** | "I need to know the second this drops." | Pin to top of Dashboard. Home Screen Widget updates. | Push Notification \+ Critical Alert (if permitted). |
| **Tier 2: Fan** | "I want to listen this week." | Standard sort order in Dashboard. | Passive "New Release" feed notification. No vibration/sound. |
| **Tier 3: Casual** | "I'll listen if I see it." | Appears in "New Releases" list. | No external notification. Discovery only. |

By capturing these preferences in the UI (Phase 1), we avoid building an expensive, one-size-fits-all notification engine in Phase 4\.

### **1.2 The Review Interface: Reducing Friction**

Analysis of **Musicboard** user feedback indicates a significant disconnect between how developers build review databases and how users actually consume music. Users frequently complain about being forced to provide a star rating just to log that they listened to an album.3 This rigid data model creates friction and discourages casual usage.

#### **1.2.1 The "Log vs. Review" Dichotomy**

To own the "Review" phase of the lifecycle, the app must distinguish between consumption (Listening) and critique (Reviewing). The UI must offer two distinct pathways:

1. **The Quick Log (Low Friction):**  
   * **Interaction:** A swipe gesture or a long-press on the album art.  
   * **Data Captured:** Timestamp, User\_ID, Release\_ID.  
   * **User Goal:** "Track my history." This mirrors the "Watched" functionality in Letterboxd, which is essential for building a listening diary without the cognitive load of writing a review.  
2. **The Deep Review (High Friction):**  
   * **Interaction:** Tapping the "Review" button opens a modal.  
   * **Data Captured:** Rating (10-point scale), Review\_Body, Listen\_Date, Tags.  
   * **Rating Scale Design:** While Beepr is purely utilitarian, review apps thrive on nuance. A 5-star system is often too coarse. A 10-point scale (or 5 stars with half-steps) allows for the granularity "music nerds" desire.5  
   * **Backdating:** A critical missing feature in early versions of Musicboard was the inability to specify *when* an album was listened to.4 The UI must include a date picker that defaults to "Now" but allows backdating to support users importing their history.

#### **1.2.2 The "Ghost Entry" Fallback System**

A fatal flaw in database-driven apps is the "Missing Album" problem. If a user listens to a leaked track, a SoundCloud exclusive, or a local band not yet on MusicBrainz, they cannot review it. This leads to user frustration and app abandonment.3

The UI must implement a **"Ghost Entry"** pattern:

1. **Search Failure:** When a search returns zero results, the UI presents a "Not found? Paste a link" option.  
2. **Instant Creation:** The user pastes a Spotify or Apple Music link. The app scrapes the OpenGraph tags (Title, Artist, Image) client-side and *immediately* creates a temporary local entry.  
3. **Optimistic UI:** The user can rate, review, and log this "Ghost Entry" immediately.  
4. **Async Resolution:** In the background, the app flags this entry for the backend to formally ingest and reconcile with the master database later. This prioritizes user agency over database purity.

### **1.3 Frontend Architecture: Flutter vs. React Native**

Given the requirements for real-time animations (confetti), high-performance list scrolling (feeds), and complex state management (countdowns), **Flutter** is the recommended framework.

* **Animation Capability:** Flutter’s Skia/Impeller rendering engine handles continuous animations (like the countdown timer and confetti) more efficiently than React Native’s bridge, which is crucial for the "Drop" moment.2  
* **Widget Ecosystem:** Packages like flutter\_confetti and slide\_to\_act are mature and fit the interactive nature of the "Hype" dashboard.  
* **Cross-Platform Consistency:** Flutter ensures the "Rolling Midnight" logic behaves identically on iOS and Android, which is vital when dealing with timezone-sensitive state transitions.

## ---

**Phase 2: Local Logic & Data Modeling**

With the UI states defined, the focus shifts to the backend. As a solo developer using Python, the choice of framework and database schema is pivotal. The backend must support the complex temporal logic defined in Phase 1 while maintaining data integrity across millions of potential music entities.

### **2.1 Backend Framework Selection: FastAPI**

While Django is the traditional choice for "batteries-included" development, **FastAPI** is recommended for this specific architecture for several reasons:

1. **Async Support:** The application relies heavily on I/O-bound operations (fetching data from Spotify/Apple APIs, sending push notifications). FastAPI’s native async/await support is superior for handling high-concurrency tasks compared to Django’s synchronous ORM history.  
2. **Pydantic Integration:** Validating external data from music APIs is messy. Pydantic (built into FastAPI) offers strict type enforcement and data validation, which is essential when normalizing data from disparate sources like MusicBrainz and Genius.7  
3. **Performance:** For a "Real-Time" app, latency matters. FastAPI provides significantly higher throughput for the lightweight JSON endpoints required by the mobile app.

### **2.2 The Data Model: Solving the Fragmentation Problem**

Music data is inherently messy. An "Album" is not a single entity; it is a collection of editions (Deluxe, Clean, Vinyl, Regional). If the data model is too rigid, reviews will be fragmented across different versions of the same album.

#### **2.2.1 The "Release Group" Architecture**

To solve fragmentation, the database schema must mimic the **MusicBrainz** structure.8 We must distinguish between the abstract *work* and the concrete *product*.

**Entity 1: Release Group (The Abstract Album)**

* **Purpose:** This is the entity users "Review" and "Hype." It aggregates all versions.  
* **Attributes:** UUID (Primary Key), Title, Primary\_Artist\_ID, First\_Release\_Date, Release\_Type (Album, EP, Single).  
* **Logic:** A review of the "Deluxe Edition" is stored as a review of the Release Group. This consolidates social proof.

**Entity 2: Release (The Concrete Product)**

* **Purpose:** This is the entity connected to the "Rolling Midnight" logic. It contains the specific release date and streaming IDs.  
* **Attributes:** UUID, Release\_Group\_ID (Foreign Key), Release\_Date, Country\_Code, Barcode (UPC/EAN), Spotify\_ID, Apple\_Music\_ID.  
* **Logic:** The "Listen" button links to the specific Spotify\_ID of the Release available in the user's region.

**Entity 3: Artist**

* **Attributes:** UUID, Name, MusicBrainz\_ID, Spotify\_ID, Apple\_Music\_ID, Image\_URL.

**Entity 4: User (Timezone-Aware)**

* **Critical Attribute:** Timezone (String, e.g., 'America/New\_York').  
* **Reasoning:** PostgreSQL stores timestamps in UTC. To calculate "Midnight Local Time," we *must* know the user's IANA timezone string.9 Storing just an offset (e.g., \-05:00) is insufficient due to Daylight Savings Time rules, which change purely based on political boundaries.

### **2.3 The "Rolling Midnight" Logic**

This is the core technical differentiator. The backend must calculate whether a release is "OUT" for a specific user without running a unique database query for every API call.

#### **2.3.1 The Timezone Logic Function**

Using Python's zoneinfo library, we can construct a robust function to determine release status.

Python

from datetime import datetime  
from zoneinfo import ZoneInfo  
from enum import Enum

class ReleaseState(Enum):  
    HYPE \= "HYPE"       \# Future  
    DROP \= "DROP"       \# Release Day (Active)  
    OUT \= "OUT"         \# Past Release Day

def get\_release\_state(release\_utc: datetime, user\_timezone\_str: str) \-\> ReleaseState:  
    """  
    Determines the state of a release for a specific user.  
    """  
    try:  
        user\_tz \= ZoneInfo(user\_timezone\_str)  
    except Exception:  
        user\_tz \= ZoneInfo("UTC") \# Fallback

    \# Get the current time in the user's specific location  
    user\_now \= datetime.now(user\_tz)  
      
    \# Releases usually happen at 00:00 local time.  
    \# We compare the user's current LOCAL date to the target release date.  
    \# Note: release\_utc in DB should represent 00:00 UTC on the release date.  
      
    release\_date\_local \= release\_utc.date()  
    user\_date\_local \= user\_now.date()

    if user\_date\_local \< release\_date\_local:  
        return ReleaseState.HYPE  
    elif user\_date\_local \== release\_date\_local:  
        return ReleaseState.DROP  
    else:  
        return ReleaseState.OUT

**Architectural Insight:** By decoupling "Server Time" from "User Wall Clock Time," we avoid the massive notification error of alerting a user in Los Angeles about a release that has only dropped in New Zealand.

### **2.4 Hype Subscription Modeling**

To power the dashboard, we need a many-to-many relationship table that tracks user interest.

**Table: HypeSubscription**

* **Columns:**  
  * id: Primary Key.  
  * user\_id: Foreign Key.  
  * release\_group\_id: Foreign Key.  
  * tier: Enum (Stan, Fan, Casual).  
  * notification\_sent: Boolean (Default False). Used to ensure idempotency in the notification worker (Phase 4).

## ---

**Phase 3: Real-World Data Integration**

Phase 3 addresses the most difficult challenge for a solo developer: sourcing accurate "Upcoming" data. Most music APIs are designed for *catalog* (what is already out) rather than *hype* (what is coming next). A successful strategy requires a hybrid ingestion pipeline that plays to the strengths of each provider while mitigating their rate limits and data gaps.

### **3.1 Comparative Analysis of Data Sources**

The research highlights distinct capabilities and limitations for the major music APIs regarding "Hype" data.

| API Provider | Hype Capability (Upcoming) | Catalog Capability (Released) | Rate Limits & Constraints | Strategic Role |
| :---- | :---- | :---- | :---- | :---- |
| **Apple Music** | **High**. Exposes isPreorder and releaseDate fields in the Catalog API.10 Often lists albums weeks before release. | **Good**. High-resolution artwork. | Token generation requires Apple Developer Program ($99/yr). Pre-release items may be "Catalog Hidden".11 | **Primary Source for Release Dates.** The best indicator of confirmed upcoming drops. |
| **MusicBrainz** | **Mixed**. "Status" field supports official vs promotion. Search allows date queries.12 | **Excellent**. The structural backbone (Release Groups). | Free. Crowd-sourced, meaning upcoming data lags until a volunteer adds it. | **Structural Backbone.** Use for linking IDs and archival data. |
| **Spotify** | **Weak**. The tag:new filter is limited to 2 weeks. The "New Releases" endpoint is broad and algorithmic.13 | **Excellent**. Rich metadata, popularity metrics, audio features. | Strict rate limits (rolling 30s window). Recent policy changes restrict non-commercial access.15 | **Link Provider.** Use only for fetching the "Listen" deep link. |
| **Genius** | **High Potential**. Crowd-sourced lyrics/tracklists often appear before audio release (leaks/announcements).16 | **Good**. Rich context (samples, producers). | API is text-heavy. Some metadata requires scraping (risky). | **Enrichment.** Source for tracklists and "Hype" content before audio is available. |

### **3.2 The Ingestion Strategy: "Lazy Loading"**

A solo developer cannot build a crawler to scan the entire internet. The ingestion strategy must be targeted and efficient, triggered by user actions rather than a global cron job.

#### **3.2.1 The "Artist Subscription" Trigger**

Instead of scraping *everything*, the system should scrape *only what users ask for*.

1. **Trigger:** User searches for "Kendrick Lamar" and clicks "Follow."  
2. **Action:** The backend triggers a background worker (Celery task) specifically for this artist.  
3. **Task Logic:**  
   * **Step 1 (MusicBrainz):** Fetch all ReleaseGroups for the artist. Update the local DB.  
   * **Step 2 (Apple Music):** Query v1/catalog/{storefront}/artists/{id}/albums. Filter results where isPreorder \== true or releaseDate \> now().10 Insert new findings into the Release table.  
   * **Step 3 (Genius):** Query artists/:id/songs sorted by date.17 This catches singles or albums announced on social media but not yet on DSPs.

#### **3.2.2 The "Rosetta Stone" Linking Logic**

To own the lifecycle, the system must link the abstract MusicBrainz entry (Hype) to the concrete Spotify ID (Listen).

* **Identifier:** **ISRC** (International Standard Recording Code).  
* **Mechanism:**  
  1. MusicBrainz entries often contain the ISRC.18  
  2. If an ISRC is present, query Spotify's Search API with q=isrc:\<code\>.14 This guarantees a 100% match.  
  3. **Fallback (Fuzzy Matching):** If no ISRC exists (common for pre-orders), use a fuzzy string matching library like **RapidFuzz** (Python) to compare Album Title \+ Artist Name.  
  4. **Threshold:** If the match score is \> 90%, auto-link. If 70-90%, flag for "Ghost Entry" manual review. Below 70%, treat as missing.

### **3.3 Defensive API Usage**

To survive as a solo dev relying on third-party data:

* **Spotify Token Rotation:** Implement a robust token management system that handles the 1-hour expiration.  
* **Apple Music Keys:** The Apple Music API requires a signed JWT (JSON Web Token). This token must be generated on the server using a private key from the Apple Developer portal. It cannot be generated on the client.  
* **Rate Limiting:** Implement "Exponential Backoff" in the Celery workers. If Spotify returns a 429 (Too Many Requests), the worker should pause for ![][image3] seconds before retrying.19

## ---

**Phase 4: Global Notification Logic**

The final phase activates the platform. The goal is to replicate Beepr's utility—notifying users the moment music drops—but with the nuance of the "Rolling Midnight" logic established in Phase 2\.

### **4.1 The "Midnight Cascade" Architecture**

We cannot simply blast all users at 00:00 UTC. The notification engine must "follow the sun," triggering alerts hour-by-hour as different timezones hit midnight.

#### **4.1.1 The Hourly Batch Job**

* **Tool:** **Celery Beat** (Scheduler) \+ **Redis** (Broker).  
* **Frequency:** Runs at the top of every hour (e.g., 10:00:00 UTC).  
* **Logic:**  
  1. **Identify Timezones:** Determine which IANA timezones have just crossed 00:00. (e.g., at 14:00 UTC, it is midnight in Australia/Brisbane).  
  2. **Select Users:** Query the User table for all users with timezone in that set.  
  3. **Select Releases:** Query the HypeSubscription table for releases dropping on *this specific date*.  
  4. **Fan-Out:** Create push notification payloads for the intersection of these sets.

**Optimization:** Use the pg\_timezone\_names view in PostgreSQL to efficiently map UTC offsets to timezone names dynamically, handling Daylight Savings Time changes automatically.20

### **4.2 Push Notification Infrastructure: OneSignal vs. Custom**

Building a custom APNS/FCM delivery pipeline is complex and error-prone. For a solo developer, **OneSignal** is the superior choice due to its "Intelligent Delivery" features.

#### **4.2.1 The "Timezone Delivery" Feature**

OneSignal allows scheduling a notification to be delivered at a specific time *in the user's local timezone*.21

* **Strategy:** Instead of running the complex "Midnight Cascade" logic (4.1.1) in Celery, we can simplify the architecture.  
* **Simplified Workflow:**  
  1. At 12:00 UTC on Day X, the backend identifies a release dropping on Day X+1.  
  2. The backend sends a **single API request** to OneSignal: "Send this message to all subscribers of Artist Y at 00:00 Local Time."  
  3. OneSignal handles the queuing, timezone offsets, and delivery.  
* **Benefit:** This removes massive complexity from the Python backend. The "Midnight Cascade" is outsourced to a specialized infrastructure provider.

### **4.3 Real-Time Dashboard Updates**

While push notifications handle the "Drop," the "Hype Dashboard" needs to update in real-time (e.g., the countdown reaching zero).

* **Problem:** Supabase's Python SDK (realtime-py) is less mature than its JavaScript counterpart, making true WebSocket subscriptions difficult to implement reliably in Python.22  
* **Solution: Client-Side Timers.**  
  * Since the "Drop" time is deterministic (00:00 local), the Flutter client does not need a server signal to unlock the UI.  
  * The client creates a local Timer based on the target\_release\_date fetched during the initial page load.  
  * When the timer hits zero, the client triggers the confetti animation and enables the "Listen" button.  
  * **Validation:** When the user clicks "Listen," the backend performs a final verification check (is\_released()) to prevent users from manipulating their system clock to access content early.

### **4.4 The "Listen" Handoff & Analytics**

The notification payload must contain the Deep Link (Spotify URI or Apple Music URL).

1. **User Tap:** The notification opens the App (not Spotify directly).  
2. **Auto-Log:** The app silently records a "Hype-to-Listen Conversion" event in the analytics.  
3. **Redirect:** The app immediately redirects the user to the streaming service.  
   * *Result:* We own the data of the conversion without adding friction to the listening experience.

## ---

**12-Week Execution Roadmap**

### **Phase 1: Foundation & Design (Weeks 1-3)**

* **Week 1:** Design "Hype Dashboard" & "Review Flow" in Flutter. Implement CountdownWidget with local state management.  
* **Week 2:** Build the "Tiered Hype" settings interface. Implement the "Ghost Entry" optimistic UI logic.  
* **Week 3:** Finalize the "Rolling Midnight" state machine interactions (Locked \-\> Confetti \-\> Unlocked).

### **Phase 2: Backend Core (Weeks 4-6)**

* **Week 4:** Initialize FastAPI project with PostgreSQL. Implement User model with timezone column validation.  
* **Week 5:** Implement ReleaseGroup and Release models (MusicBrainz schema). Write and test the get\_release\_state() Python logic.  
* **Week 6:** Build internal API endpoints (GET /dashboard, POST /review). Implement Pydantic schemas for data validation.

### **Phase 3: Data Pipeline (Weeks 7-9)**

* **Week 7:** Integrate MusicBrainz API for artist/release group search. Build the "Artist Subscription" Celery trigger.  
* **Week 8:** Integrate Apple Music API (JWT auth) to fetch isPreorder data. Integrate Spotify API for ISRC matching.  
* **Week 9:** Implement "Lazy Loading" background workers. Set up Redis for caching API responses.

### **Phase 4: Notification & Launch (Weeks 10-12)**

* **Week 10:** Integrate OneSignal SDK. Configure "Timezone Delivery" segments based on User tags.  
* **Week 11:** Implement "Hype Unlocking" logic verification (Server-side check). Refine the "Listen" deep link redirect flow.  
* **Week 12:** Beta testing. Verify "Rolling Midnight" logic with users in different timezones. Stress test the "Ghost Entry" reconciliation system.

By adhering to this roadmap, the solo developer leverages the "UI-First" approach to define the product's value proposition early, while the backend architecture is specifically engineered to handle the unique temporal challenges of the global music industry. This results in a platform that offers the utility of Beepr and the depth of Letterboxd, minimizing technical debt and maximizing user engagement.

#### **Works cited**

1. Beeper \- Ratings & Reviews \- App Store \- Apple, accessed January 26, 2026, [https://apps.apple.com/us/app/beeper/id6499013100?see-all=reviews\&platform=iphone](https://apps.apple.com/us/app/beeper/id6499013100?see-all=reviews&platform=iphone)  
2. flutter\_confetti | Flutter package \- Pub.dev, accessed January 26, 2026, [https://pub.dev/packages/flutter\_confetti](https://pub.dev/packages/flutter_confetti)  
3. What is going on with this app? : r/musicboard \- Reddit, accessed January 26, 2026, [https://www.reddit.com/r/musicboard/comments/1osif8u/what\_is\_going\_on\_with\_this\_app/](https://www.reddit.com/r/musicboard/comments/1osif8u/what_is_going_on_with_this_app/)  
4. App shutting down? : r/musicboard \- Reddit, accessed January 26, 2026, [https://www.reddit.com/r/musicboard/comments/1o5lqa2/app\_shutting\_down/](https://www.reddit.com/r/musicboard/comments/1o5lqa2/app_shutting_down/)  
5. Wavelength \- Rate Your Music \- App Store \- Apple, accessed January 26, 2026, [https://apps.apple.com/us/app/wavelength-rate-your-music/id6756295934](https://apps.apple.com/us/app/wavelength-rate-your-music/id6756295934)  
6. flutter\_advanced\_countdown | Flutter package \- Pub.dev, accessed January 26, 2026, [https://pub.dev/packages/flutter\_advanced\_countdown](https://pub.dev/packages/flutter_advanced_countdown)  
7. Timezone Name \- Pydantic Validation, accessed January 26, 2026, [https://docs.pydantic.dev/latest/api/pydantic\_extra\_types\_timezone\_name/](https://docs.pydantic.dev/latest/api/pydantic_extra_types_timezone_name/)  
8. Release \- MusicBrainz, accessed January 26, 2026, [https://musicbrainz.org/doc/Release](https://musicbrainz.org/doc/Release)  
9. How to keep time zone information for timestamps in PostgreSQL \- AboutBits, accessed January 26, 2026, [https://aboutbits.it/blog/2022-11-08-storing-timestamps-with-timezones-in-postgres](https://aboutbits.it/blog/2022-11-08-storing-timestamps-with-timezones-in-postgres)  
10. Albums | Apple Developer Documentation, accessed January 26, 2026, [https://developer.apple.com/documentation/applemusicapi/albums-api?changes=\_3](https://developer.apple.com/documentation/applemusicapi/albums-api?changes=_3)  
11. Why is music being hid from iTunes/Apple Music \- Apple Support Communities, accessed January 26, 2026, [https://discussions.apple.com/thread/252953978](https://discussions.apple.com/thread/252953978)  
12. Search for new release \- Development \- MetaBrainz Community Discourse, accessed January 26, 2026, [https://community.metabrainz.org/t/search-for-new-release/692914](https://community.metabrainz.org/t/search-for-new-release/692914)  
13. Get New Releases \- Web API Reference | Spotify for Developers, accessed January 26, 2026, [https://developer.spotify.com/documentation/web-api/reference/get-new-releases](https://developer.spotify.com/documentation/web-api/reference/get-new-releases)  
14. Web API Reference \- Spotify for Developers, accessed January 26, 2026, [https://developer.spotify.com/documentation/web-api/reference/search](https://developer.spotify.com/documentation/web-api/reference/search)  
15. Spotify just killed indie development with their new API restrictions : r/truespotify \- Reddit, accessed January 26, 2026, [https://www.reddit.com/r/truespotify/comments/1l2am4i/spotify\_just\_killed\_indie\_development\_with\_their/](https://www.reddit.com/r/truespotify/comments/1l2am4i/spotify_just_killed_indie_development_with_their/)  
16. Getting Song Lyrics from Genius's API \+ Scraping | Big-Ish Data, accessed January 26, 2026, [https://bigishdata.com/2016/09/27/getting-song-lyrics-from-geniuss-api-scraping/](https://bigishdata.com/2016/09/27/getting-song-lyrics-from-geniuss-api-scraping/)  
17. API — lyricsgenius documentation \- Read the Docs, accessed January 26, 2026, [https://lyricsgenius.readthedocs.io/en/master/reference/api.html](https://lyricsgenius.readthedocs.io/en/master/reference/api.html)  
18. ISRC \- MusicBrainz, accessed January 26, 2026, [https://musicbrainz.org/doc/ISRC](https://musicbrainz.org/doc/ISRC)  
19. Rate Limits \- Spotify for Developers, accessed January 26, 2026, [https://developer.spotify.com/documentation/web-api/concepts/rate-limits](https://developer.spotify.com/documentation/web-api/concepts/rate-limits)  
20. How to get the timezone from a PostgreSQL timestamp, accessed January 26, 2026, [https://dba.stackexchange.com/questions/164203/how-to-get-the-timezone-from-a-postgresql-timestamp](https://dba.stackexchange.com/questions/164203/how-to-get-the-timezone-from-a-postgresql-timestamp)  
21. Scheduling Push Notifications by User Time Zone \- OneSignal, accessed January 26, 2026, [https://onesignal.com/blog/deliver-by-timezone-push-notification/](https://onesignal.com/blog/deliver-by-timezone-push-notification/)  
22. Realtime Subscriptions with Python · supabase · Discussion \#25990 \- GitHub, accessed January 26, 2026, [https://github.com/orgs/supabase/discussions/25990](https://github.com/orgs/supabase/discussions/25990)

Run test: flutter run \-d web-server \--web-port 8080 \--web-hostname 0.0.0.0

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAAXCAYAAADpwXTaAAAAiElEQVR4XmNgGAWjgGqAA4jTgJgHXYIcwAjErUBsjC5BLgAZ1AvELOgS5ACQ6wqAOA7KRgECQCxJIpYD4vlAPBmI+RiggBuIq4F4Fhl4BxB/BeJmIGZnoACYAPFqIJZBlyAVCAPxYiCWR5cgB2QBcQS6IDkAlGinArE0ugQ5AJQUeKH0KBhMAABVixNKp22j3QAAAABJRU5ErkJggg==>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACsAAAAYCAYAAABjswTDAAABcklEQVR4Xu2VMSgGYRjHH6GIECJRislgUiajxWARpQxKyUgWpQySxWiUbBJZSTEarAaLFEmZjAYUfs+975u77+7Vd6n3G9yvft313HPd8333f98TKSgo+AtNuIg7uIZdyctJ5vAc20ovBKAXr3Ee63AMb3E43uTQhhOrnoekBnfx2J47NvEM62O1iB58EtMQmj58xpWS+gS+4pArNIrJxhR+4DR2Yq1rCMAofkp62HH8whlXmBUT6Ht8w33cxn7XEAA3lG/YRD1vXnWlPuZQc9ca3ZmNDpMaSjzDVjKvyrJkDCWeYTUz7/ZYCTKH8tVXxaxGXZXl4BZluXZgdXRnNiNiFrdvWN0VIlxeL7BBzC6wJSYaPgZxMoe6waf2yhjd+CBmYcdZwBcccIV2vJGfvOqvWMIq1xAAfdYGXmGzremfdoQHEvtQaOM63uGhPQ+5xzp0yFMxM+ib2MNL8bzhFmsl0Vzr10qjo8ffcl5QUPBv+QaDd1BfU9HZuwAAAABJRU5ErkJggg==>

[image3]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAAXCAYAAADpwXTaAAABOElEQVR4Xu3STysFURjH8Uf+lEspbKTuQjaysFBsKCtW7sIruKFspLAQpXgDipVsLZQslJBYKFbeBSk7C8VOfH/3PDP3mMjF0v3VpznnzJkzTzOPWTV/SQdWsYN1dH+8bePYRy+mcYoiaqI9pQzgHMPowzHesGhhcyemsIIztFp4+aVf0zTiEJOo9bU23OAZ/RYezuMIBd+j9Wu0+7wUnXyLJwtVJVEVqm7B56ruCl0+n8WWj9PUY9NC+XHJSxYO01UZwgmancb6LHOWqS6bOhzgFSO+pgrXfKzD9iz8sDFf+zKDFr6X/qwqVxqisaLvm4vmn6YFF9hFU+bej6I3b2PDwl/+dZKDlq3cIj0YTXdUGDWmGnTex0lmMBHNv40eLuIF97iLPFpoiYqTNK16KuvByk1azb/KO5XrNPuq2kZkAAAAAElFTkSuQmCC>