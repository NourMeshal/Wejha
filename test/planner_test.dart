import 'package:flutter_test/flutter_test.dart';
import 'package:visit_kuwait/data/catalog.dart';
import 'package:visit_kuwait/engine/planner.dart';
import 'package:visit_kuwait/models/trip.dart';

void main() {
  Prefs prefs({String arrive = '2026-11-12', int days = 4, int kids = 0, List<String>? interests, String pace = 'balanced'}) => Prefs(
        arrive: arrive,
        depart: addDays(arrive, days - 1),
        kids: kids,
        youngest: kids > 0 ? 5 : null,
        interests: interests ?? ['concerts', 'kuwaiti_food', 'shopping', 'theatre', 'culture'],
        pace: pace,
      );

  void expectValid(Trip trip) {
    for (final d in trip.days) {
      for (var i = 1; i < d.items.length; i++) {
        final a = d.items[i - 1], b = d.items[i];
        expect(a.end <= b.start, isTrue, reason: '${d.date}: ${a.ref} overlaps ${b.ref}');
        if (b.kind != ItemKind.depart) {
          expect(a.end + (b.travel ?? 0) <= b.start, isTrue, reason: '${d.date}: no travel time before ${b.ref}');
        }
      }
      for (final it in d.items.where((i) => i.ref != null && !catalog[i.ref]!.isEvent)) {
        final c = catalog[it.ref]!;
        final open = openWindows(c, d.date).any((w) => w[0] <= it.start && it.end <= w[1]);
        expect(open, isTrue, reason: '${c.id} scheduled while closed on ${d.date}');
      }
    }
  }

  test('no overlaps, travel time respected, places open', () {
    for (final pace in ['relaxed', 'balanced', 'busy']) {
      expectValid(makeTrip(prefs(pace: pace), {}));
    }
  });

  test('summer trip keeps outdoor stops out of midday heat', () {
    final trip = makeTrip(prefs(arrive: '2026-07-09', interests: ['beaches', 'family', 'museums']), {});
    expectValid(trip);
    for (final d in trip.days) {
      for (final it in d.items.where((i) => i.ref != null)) {
        final c = catalog[it.ref]!;
        if (!c.indoor) expect(overlaps(it.start, it.end, 660, 1050), isFalse, reason: '${c.id} outdoors at midday');
      }
    }
  });

  test('age limits respected with a 5-year-old', () {
    final trip = makeTrip(prefs(kids: 1), {});
    for (final d in trip.days) {
      for (final it in d.items.where((i) => i.ref != null)) {
        expect(catalog[it.ref]!.minAge <= 5, isTrue);
      }
    }
  });

  test('pinned items survive a rebuild', () {
    final trip = makeTrip(prefs(), {});
    final item = trip.days[1].items.firstWhere((i) => i.ref != null);
    item.kept = true;
    rebuildDay(trip, 1, {}, 'busy');
    expect(trip.days[1].items.any((i) => i.uid == item.uid), isTrue);
    expectValid(trip);
  });

  test('JSON round trip', () {
    final trip = makeTrip(prefs(), {});
    final back = Trip.fromJson(trip.toJson());
    expect(back.days.length, trip.days.length);
    expect(back.days[1].items.length, trip.days[1].items.length);
  });
}
