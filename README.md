# Visit Kuwait — Flutter app (v0.1 prototype)

A bilingual (English / Arabic, full RTL) trip planner for visitors to Kuwait.
Visitors answer four questions; the app builds a day-by-day plan that respects
opening hours, event times, seats, travel time, budget, age limits and the summer heat.

## Run it

1. Install Flutter (stable): https://docs.flutter.dev/get-started/install
2. In this folder, generate the platform folders (your `lib/` and `test/` are kept):
   ```bash
   flutter create --org com.visitkuwait --platforms=android,ios,web .
   flutter pub get
   ```
3. Run:
   ```bash
   flutter run            # phone or emulator
   flutter run -d chrome  # web
   flutter test           # planner tests
   ```
4. Android release builds only: add `<uses-permission android:name="android.permission.INTERNET"/>`
   to `android/app/src/main/AndroidManifest.xml` (needed for fonts and map tiles).

If `flutter analyze` reports something, paste it to Claude and fix it before moving on.

## What's inside

```
lib/
  main.dart                 App, theme, language, bottom nav / side rail
  theme.dart                Blue palette + Cairo font (Latin and Arabic)
  l10n/strings.dart         English and Arabic text
  data/catalog.dart         Seed places, restaurants, venues, demo events
  models/trip.dart          Prefs, Trip, TripDay, TripItem (+ JSON)
  engine/planner.dart       The scheduler: fits activities into each day
  state/app_state.dart      App state, saving, formatting helpers
  screens/                  Home, Onboarding (4 steps), Trip, Discover, Concierge, Profile
  widgets/                  Activity card, map, bottom sheets, shared bits
test/planner_test.dart      No overlaps, travel time, opening hours, heat, age, pinning
```

## Rules the code follows

- **Never invent transactional data.** Event times, seats and prices in `catalog.dart` are
  marked `demo: true` and the app shows an "example data" banner. Real data comes from the
  admin dashboard or signed partners only.
- **Never say "booked" on our own.** An item becomes `confirmed` only when a provider confirms
  it, or the visitor enters a confirmation number.
- **AI suggests, the planner decides.** Any AI concierge must return actions that go through
  `engine/planner.dart`, which checks hours, travel and seats.
- **No secrets in the app.** AI and partner API keys live on the backend only.

## Booking partners (status)

| Partner | What | Status |
|---|---|---|
| Eventat | Concerts, plays, local events | Official link only — request partner API |
| The Arena Kuwait | Arena events | Official link only — they state their website is the only official ticket channel |
| Cinescape | Showtimes | Official link only — request a feed |
| Restaurant platform | Tables | Not connected |
| Google Maps | Directions | Link |

Do not scrape partner websites. Use official links until there is an agreement.

## Roadmap

**v0.2 — real data**
- Backend: FastAPI or Node + PostgreSQL with PostGIS. Move `planner.dart` logic there.
- Admin dashboard to add real events (dates, times, prices, booking link).
- Google Places API for real restaurants/attractions (hours, photos) — key on the server.
- Paid map tiles (Mapbox/MapTiler) — OpenStreetMap tiles are for development only.

**v0.3 — accounts and AI**
- Sign-in (only needed to save trips across devices).
- AI concierge through the backend: model returns actions; planner validates them.

**v0.4 — partners**
- First partner integration (Eventat recommended), booking status sync, tickets in My Trip.
