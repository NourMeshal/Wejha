# Notes for Claude Code

Project: Visit Kuwait, a Flutter trip planner for visitors to Kuwait (English + Arabic RTL).

## Conventions
- Font: Cairo via google_fonts for both languages. Palette in lib/theme.dart (VK class). Keep the UI simple:
  big tap targets (min 44px), one primary action per card, secondary actions in the "Change" menu.
- All user-facing text goes in lib/l10n/strings.dart with BOTH 'en' and 'ar' keys (test/widget_test.dart checks this).
- Use EdgeInsetsDirectional / AlignmentDirectional so layouts flip correctly in Arabic.
- State: AppState (ChangeNotifier) exposed through AppScope.of(context). No extra state package yet.

## Hard rules
- Never invent events, prices, seats, hours or booking confirmations. Demo data stays flagged `demo: true`.
- Only set BookingStatus.confirmed from a provider response or a visitor-entered confirmation number.
- Any change to the itinerary must go through lib/engine/planner.dart (fitAt / tryPlace) so hours,
  travel time and seats are checked. Run `flutter test` after touching the planner.
- No API keys in the app. Partners, Google Places and AI calls go through the backend.
- Do not scrape Eventat, The Arena, Cinescape or other partner sites.

## Commands
flutter pub get | flutter analyze | flutter test | flutter run -d chrome
