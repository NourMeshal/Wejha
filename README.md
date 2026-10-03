# Visit Kuwait — Flutter app

A bilingual (English / Arabic, RTL) trip planner for visitors to Kuwait. Answer four questions and get a day-by-day plan that respects opening hours, event times, travel time, budget and the summer heat.

## Run it

```bash
flutter create --org com.visitkuwait --platforms=android,ios,web .
flutter pub get
flutter run -d chrome
flutter test
```

Android only: add `<uses-permission android:name="android.permission.INTERNET"/>` to `android/app/src/main/AndroidManifest.xml`.

## Rules

- **No invented data.** Events, seats and prices in `catalog.dart` are `demo: true`. Real data comes from the admin dashboard or partners only.
- **No fake confirmations.** An item becomes `confirmed` only when a provider confirms it or the visitor enters a confirmation number.
- **Planner owns the schedule.** All itinerary changes go through `engine/planner.dart`.
- **No secrets in the app.** API keys live on the backend only.

## Contributors

- [@nourmeshal](https://github.com/nourmeshal)
