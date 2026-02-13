# Epic 3: Data Integration Pipeline

**Weeks:** 7–9  
**Phase:** Data Pipeline

---

## Objectives (from roadmap)

- **Lazy loading:** Ingest data when users act (e.g. "Follow Artist"); avoid global crawls.
- **MusicBrainz:** Structural backbone (Release Groups, linking); search for artist/release groups.
- **Apple Music:** Primary source for upcoming release dates (isPreorder, releaseDate); JWT auth.
- **Spotify:** Link provider for "Listen" deep link; ISRC search for matching.
- **Genius:** Enrichment (tracklists, hype content); artist/songs by date.
- **Rosetta Stone linking:** ISRC where available; fuzzy match (e.g. RapidFuzz) for Album + Artist; 90% auto-link, 70–90% flag for review.
- **Defensive API usage:** Spotify token rotation (1h), Apple Music JWT from server, exponential backoff on 429.

---

## Milestones

### M3.1 – MusicBrainz and artist trigger (Week 7)

- MusicBrainz API integration for artist and release-group search.
- On "Follow Artist," enqueue Celery task to fetch release groups for that artist and update DB.

### M3.2 – Apple Music and Spotify (Week 8)

- Apple Music: JWT auth, catalog API; fetch albums with isPreorder / releaseDate for artist.
- Spotify: search and link; ISRC-based linking (`q=isrc:<code>`); fuzzy fallback (RapidFuzz), 90% auto-link, 70–90% manual review.

### M3.3 – Workers and resilience (Week 9)

- Lazy-loading Celery workers: Apple Music preorders, Genius artist/songs by date.
- Redis for caching API responses.
- Spotify token rotation; exponential backoff on 429.

---

## User stories

- As a **user**, I want to follow an artist and see their upcoming releases so that my dashboard stays relevant.
- As the **system**, I want to fetch release dates from Apple Music when a user follows an artist so that we have accurate hype data.
- As the **system**, I want to link MusicBrainz releases to Spotify/Apple so that "Listen" opens the right album.
- As the **system**, I want to handle API limits and token expiry so that ingestion is reliable.
