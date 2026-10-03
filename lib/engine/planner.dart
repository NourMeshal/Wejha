// Deterministic itinerary planner.
// The AI may suggest WHAT a visitor would enjoy; this code decides whether it
// actually FITS: opening hours, event times, seats, travel time, budget,
// age, accessibility, heat and pace. Nothing here invents data.
// Later this moves to the backend so the app and website share one planner.

import 'dart:math' as math;

import '../data/catalog.dart';
import '../models/trip.dart';

const climateHighs = [19, 22, 27, 34, 41, 46, 47, 47, 43, 37, 27, 21]; // typical, not a forecast
const budgetCap = {'economical': 8.0, 'moderate': 20.0, 'premium': 45.0, 'luxury': 1e9};

class PaceCfg {
  final int start, end, max, brk;
  const PaceCfg(this.start, this.end, this.max, this.brk);
}

const paces = {
  'relaxed': PaceCfg(600, 1350, 2, 90),
  'balanced': PaceCfg(570, 1380, 3, 60),
  'busy': PaceCfg(540, 1410, 5, 0),
};

/* ---------------- dates & geometry ---------------- */

DateTime parseDate(String s) {
  final p = s.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

String dateStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String addDays(String s, int n) {
  final d = parseDate(s);
  return dateStr(DateTime(d.year, d.month, d.day + n));
}

/// 0 = Sunday ... 6 = Saturday (Kuwait weekend is Fri/Sat = 5/6)
int weekday(String s) => parseDate(s).weekday % 7;
int monthOf(String s) => parseDate(s).month;

double haversine(double la1, double lo1, double la2, double lo2) {
  const r = 6371.0, rad = math.pi / 180;
  final dLa = (la2 - la1) * rad, dLo = (lo2 - lo1) * rad;
  final x = math.pow(math.sin(dLa / 2), 2) +
      math.cos(la1 * rad) * math.cos(la2 * rad) * math.pow(math.sin(dLo / 2), 2);
  return 2 * r * math.asin(math.sqrt(x));
}

int travelMinutes(double la1, double lo1, double la2, double lo2, String mode) {
  final d = haversine(la1, lo1, la2, lo2);
  if (d < 0.25) return 0;
  if (mode == 'walk' && d < 1.5) return math.max(5, (d * 13).round());
  if (mode == 'bus') return (d * 1.35 / 18 * 60).round() + 12;
  return math.max(6, (d * 1.35 / 40 * 60).round() + 7);
}

bool overlaps(int a1, int a2, int b1, int b2) => a1 < b2 && b1 < a2;
int roundUp15(int m) => ((m + 14) ~/ 15) * 15;

/// FNV-1a, 32 bit, safe on web (no 64-bit multiplication).
int fnv(String s) {
  var h = 0x811c9dc5;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (((h << 24) & 0xffffffff) + h * 403) & 0xffffffff;
  }
  return h;
}

int _uidCounter = 0;
String newUid() => 'i${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${(_uidCounter++).toRadixString(36)}';

double groupCost(Listing c, Prefs p, [double? price]) {
  final pr = price ?? c.price;
  if (pr == 0) return 0;
  return p.adults * pr + p.kids * (c.child ?? pr);
}

List<List<int>> openWindows(Listing c, String date) {
  final w = weekday(date);
  if (c.except.containsKey(w)) return c.except[w]!;
  return c.hours;
}

/* ---------------- events ---------------- */

class Occurrence {
  final Listing ev;
  final String id, date;
  final int start, end, seats, updatedMin;
  Occurrence(this.ev, this.id, this.date, this.start, this.end, this.seats, this.updatedMin);
}

/// DEMO: generates example performances. Replace with the events table / partner feed.
List<Occurrence> occurrencesOn(String date) {
  final out = <Occurrence>[];
  for (final ev in events) {
    if (ev.months != null && !ev.months!.contains(monthOf(date))) continue;
    if (ev.days != null && !ev.days!.contains(weekday(date))) continue;
    for (final t in ev.times) {
      final id = '${ev.id}@$date@$t';
      final hh = fnv(id);
      final seats = hh % 9 == 0 ? 0 : (hh % 140) + 2;
      out.add(Occurrence(ev, id, date, t, t + ev.dur, seats, (hh % 50) + 5));
    }
  }
  return out;
}

/* ---------------- context ---------------- */

class Bounds {
  final int s, e, eh;
  const Bounds(this.s, this.e, this.eh);
}

class Ctx {
  final Prefs p;
  final String date;
  final int month;
  final bool hot;
  final Hotel hotel;
  final Set<String> hidden;
  final Set<String> used = {};
  final Set<String> usedEv = {};
  final Map<String, double> catCount = {};
  final Map<String, int> restUse = {};
  double spent = 0;
  Ctx(this.p, this.date, this.hidden)
      : month = monthOf(date),
        hot = climateHighs[monthOf(date) - 1] >= 38,
        hotel = hotels[p.hotel] ?? hotels['city']!;
  String get mode => p.transport;
}

String dayPace(Trip t, int di) => t.days[di].pace ?? t.prefs.pace;

Bounds dayBounds(Trip t, int di) {
  final p = t.prefs, n = t.days.length, pc = paces[dayPace(t, di)]!;
  var s = pc.start, e = pc.end, eh = 1470;
  if (di == 0) s = math.max(s, p.arriveT + 120);
  if (di == n - 1) {
    final dep = p.departT - 180;
    e = math.min(e, dep);
    eh = math.min(eh, dep);
  }
  return Bounds(s, e, eh);
}

Ctx makeCtx(Trip t, int di, Set<String> hidden, {String? excludeUid}) {
  final ctx = Ctx(t.prefs, t.days[di].date, hidden);
  for (var j = 0; j < t.days.length; j++) {
    for (final it in t.days[j].items) {
      if (it.uid == excludeUid || it.status == BookingStatus.cancelled || it.ref == null) continue;
      final c = catalog[it.ref]!;
      if (!c.isRestaurant || j == di) ctx.used.add(c.id);
      if (c.isRestaurant) ctx.restUse[c.id] = (ctx.restUse[c.id] ?? 0) + 1;
      if (c.isEvent) ctx.usedEv.add(c.id);
      ctx.catCount[c.cat] = (ctx.catCount[c.cat] ?? 0) + (c.isRestaurant ? .5 : 1);
      ctx.spent += groupCost(c, t.prefs, it.price);
    }
  }
  return ctx;
}

bool eligible(Listing c, Ctx ctx, [int? start, int? end]) {
  final p = ctx.p;
  if (ctx.hidden.contains(c.id)) return false;
  if (c.months != null && !c.months!.contains(ctx.month)) return false;
  if (p.kids > 0 && c.minAge > 0) {
    if (p.youngest != null && p.youngest! < c.minAge) return false;
    if (p.youngest == null && c.minAge >= 12) return false;
  }
  if (c.price > (budgetCap[p.budget] ?? 20)) return false;
  if (p.customBudget != null && ctx.spent + groupCost(c, p) > p.customBudget!) return false;
  if (p.indoor && !c.indoor) return false;
  if (p.access.contains('wheelchair') && !c.acc) return false;
  if (c.isRestaurant && (p.diet.contains('vegetarian') || p.diet.contains('vegan')) && !c.veg) return false;
  if (ctx.hot && !c.indoor && start != null && end != null && overlaps(start, end, 660, 1050)) return false;
  return true;
}

class Scored {
  final double s;
  final List<Why> why;
  const Scored(this.s, this.why);
}

Scored score(Listing c, Ctx ctx, double fromLat, double fromLng, [int? t]) {
  final p = ctx.p;
  final why = <Why>[];
  var s = 0.0;
  final m = c.tags.where(p.interests.contains).toList();
  if (m.isNotEmpty) {
    s += 3 + m.length * 1.5;
    why.add(Why('match', v: m.take(3).toList()));
  } else if (p.interests.isNotEmpty) {
    s -= 1.5;
  }
  s += c.pop * 2;
  if (c.isEvent) {
    s += 2;
    why.add(const Why('dated'));
  }
  s -= (ctx.catCount[c.cat] ?? 0) * 2.2;
  if (c.isRestaurant) s -= (ctx.restUse[c.id] ?? 0) * 3.5;
  final d = haversine(fromLat, fromLng, c.lat, c.lng);
  s -= d * 0.07;
  if (d < 3 && d >= .25) why.add(Why('near', d: d));
  if (p.kids > 0 && (c.tags.contains('family') || c.tags.contains('kids'))) {
    s += 1.5;
    why.add(const Why('family'));
  }
  if (ctx.hot && c.indoor && t != null && t >= 660 && t <= 1020) {
    s += .8;
    why.add(const Why('cool'));
  }
  return Scored(s, why);
}

/* ---------------- fitting ---------------- */

TripItem? prevOf(List<TripItem> items, int t) {
  TripItem? p;
  for (final it in items) {
    if (it.status == BookingStatus.cancelled) continue;
    if (it.end <= t && (p == null || it.end > p.end)) p = it;
  }
  return p;
}

bool fitAt(List<TripItem> items, int start, int end, double lat, double lng, Ctx ctx, Bounds b, bool hard) {
  TripItem? prev, next;
  for (final it in items) {
    if (it.status == BookingStatus.cancelled) continue;
    if (overlaps(start, end, it.start, it.end)) return false;
    if (it.end <= start && (prev == null || it.end > prev.end)) prev = it;
    if (it.start >= end && (next == null || it.start < next.start)) next = it;
  }
  final pLat = prev?.lat ?? ctx.hotel.lat, pLng = prev?.lng ?? ctx.hotel.lng;
  final pEnd = prev?.end ?? b.s;
  if (pEnd + travelMinutes(pLat, pLng, lat, lng, ctx.mode) > start) return false;
  if (next != null) {
    if (end + travelMinutes(lat, lng, next.lat, next.lng, ctx.mode) > next.start) return false;
  } else if (end > (hard ? b.eh : b.e)) {
    return false;
  }
  return true;
}

/// Earliest feasible start for listing [c] with duration [dur] in [lo, hi].
int? tryPlace(Listing c, int dur, List<TripItem> items, Ctx ctx, Bounds b, int lo, int hi, {int? maxWait}) {
  for (final w in openWindows(c, ctx.date)) {
    var t = roundUp15(math.max(lo, w[0]));
    for (; t + dur <= w[1] && t <= hi; t += 15) {
      if (maxWait != null && t - lo > maxWait) break;
      if (!eligible(c, ctx, t, t + dur)) continue;
      if (fitAt(items, t, t + dur, c.lat, c.lng, ctx, b, false)) return t;
    }
  }
  return null;
}

TripItem _mk(ItemKind kind, Listing? c, int start, int end,
    {String? meal, String? occ, int? seats, double? price, List<Why>? why, double? lat, double? lng}) {
  return TripItem(
    uid: newUid(), kind: kind, ref: c?.id, meal: meal, start: start, end: end,
    lat: lat ?? c!.lat, lng: lng ?? c!.lng, occ: occ, seats: seats, price: price, why: why,
    status: kind == ItemKind.event ? BookingStatus.available : BookingStatus.recommended,
  );
}

void _sort(List<TripItem> items) => items.sort((a, b) => a.start.compareTo(b.start));

/* ---------------- build ---------------- */

void buildDay(Trip trip, int di, List<TripItem> fixed, Set<String> hidden) {
  final day = trip.days[di], p = trip.prefs, b = dayBounds(trip, di), pc = paces[dayPace(trip, di)]!;
  final n = trip.days.length;
  day.items = fixed.map((x) => x.clone()).toList();
  final items = day.items;
  _sort(items);
  final ctx = makeCtx(trip, di, hidden);
  final special = di == 0 || di == n - 1;
  final maxAct = special ? math.max(1, (pc.max / 2).ceil()) : pc.max;

  void add(TripItem it, Listing? c) {
    items.add(it);
    _sort(items);
    if (c == null) return;
    ctx.used.add(c.id);
    if (c.isEvent) ctx.usedEv.add(c.id);
    if (c.isRestaurant) ctx.restUse[c.id] = (ctx.restUse[c.id] ?? 0) + 1;
    ctx.catCount[c.cat] = (ctx.catCount[c.cat] ?? 0) + (c.isRestaurant ? .5 : 1);
    ctx.spent += groupCost(c, p, it.price);
  }

  if (b.s >= b.e) {
    finalize(trip, di);
    return;
  }

  // 1) dated events that match interests
  final evCap = pc.max >= 5 ? 2 : 1;
  var evCount = items.where((i) => i.kind == ItemKind.event).length;
  final occs = occurrencesOn(day.date)
      .where((o) => !ctx.usedEv.contains(o.ev.id) && o.seats >= p.party && o.start >= b.s)
      .map((o) {
        final from = prevOf(items, o.start);
        return (o: o, sc: score(o.ev, ctx, from?.lat ?? ctx.hotel.lat, from?.lng ?? ctx.hotel.lng, o.start));
      })
      .where((x) => x.sc.why.any((w) => w.k == 'match'))
      .toList()
    ..sort((a, c) => c.sc.s.compareTo(a.sc.s));
  for (final x in occs) {
    if (evCount >= evCap) break;
    final o = x.o;
    if (ctx.usedEv.contains(o.ev.id)) continue;
    if (!eligible(o.ev, ctx, o.start, o.end)) continue;
    if (!fitAt(items, o.start, o.end, o.ev.lat, o.ev.lng, ctx, b, true)) continue;
    add(_mk(ItemKind.event, o.ev, o.start, o.end, occ: o.id, seats: o.seats, price: o.ev.price, why: x.sc.why), o.ev);
    evCount++;
  }

  // 2) meals
  final meals = <(String, int, int, int)>[];
  if (di > 0 && b.s <= 630) meals.add(('b', b.s, b.s + 15, 60));
  meals.add(('l', 750, 840, 75));
  meals.add(('d', 1110, 1275, 90));
  for (final (mt, lo, hi, dur) in meals) {
    if (items.any((i) => i.kind == ItemKind.meal && i.meal == mt)) continue;
    ({Listing c, int t, double v, Scored sc, int d})? best;
    void tryWin(int lo2, int hi2, int d2) {
      for (final c in places) {
        if (!c.isRestaurant || !c.meals.contains(mt) || ctx.used.contains(c.id)) continue;
        final t = tryPlace(c, d2, items, ctx, b, lo2, hi2);
        if (t == null) continue;
        final from = prevOf(items, t);
        final sc = score(c, ctx, from?.lat ?? ctx.hotel.lat, from?.lng ?? ctx.hotel.lng, t);
        final v = sc.s - (t - lo2) * .01;
        if (best == null || v > best!.v) best = (c: c, t: t, v: v, sc: sc, d: d2);
      }
    }

    tryWin(lo, hi, dur);
    if (best == null && mt == 'd') tryWin(1305, 1350, 75);
    final bb = best;
    if (bb != null) {
      add(_mk(ItemKind.meal, bb.c, bb.t, bb.t + bb.d, meal: mt, price: bb.c.price, why: bb.sc.why), bb.c);
    }
  }

  // 3) rest at the hotel
  if (pc.brk > 0 && !special && !items.any((i) => i.kind == ItemKind.hotelBreak)) {
    for (final t in [960, 930, 990, 900, 1020]) {
      if (fitAt(items, t, t + pc.brk, ctx.hotel.lat, ctx.hotel.lng, ctx, b, false)) {
        add(_mk(ItemKind.hotelBreak, null, t, t + pc.brk, lat: ctx.hotel.lat, lng: ctx.hotel.lng), null);
        break;
      }
    }
  }

  // 4) activities, greedy over the gaps
  final pool = places
      .where((c) => !c.isRestaurant || (c.meals.contains('s') && c.tags.any(p.interests.contains)))
      .toList();
  var count = items.where((i) => i.isActivity).length;
  var guard = 0;
  while (count < maxAct && guard++ < 12) {
    ({Listing c, int dur, int t, double v, Scored sc})? best;
    final sorted = items.where((i) => i.status != BookingStatus.cancelled).toList();
    for (var g = 0; g <= sorted.length; g++) {
      final a = g == 0 ? null : sorted[g - 1];
      final nx = g < sorted.length ? sorted[g] : null;
      final lo = a?.end ?? b.s, hi = nx?.start ?? b.e;
      if (hi - lo < 45) continue;
      for (final c in pool) {
        if (ctx.used.contains(c.id)) continue;
        final dur = c.isRestaurant ? 45 : c.dur;
        final t = tryPlace(c, dur, items, ctx, b, lo, hi - dur, maxWait: 120);
        if (t == null) continue;
        final fLat = a?.lat ?? ctx.hotel.lat, fLng = a?.lng ?? ctx.hotel.lng;
        final sc = score(c, ctx, fLat, fLng, t);
        final wait = math.max(0, t - lo - travelMinutes(fLat, fLng, c.lat, c.lng, ctx.mode));
        final v = sc.s - wait * .01 - (c.isRestaurant ? 1 : 0);
        if (best == null || v > best.v) best = (c: c, dur: dur, t: t, v: v, sc: sc);
      }
    }
    if (best == null || best.v < .5) break;
    add(_mk(ItemKind.place, best.c, best.t, best.t + best.dur, price: best.c.price, why: best.sc.why), best.c);
    count++;
  }
  finalize(trip, di);
}

void finalize(Trip trip, int di) {
  final day = trip.days[di], p = trip.prefs;
  final hotel = hotels[p.hotel] ?? hotels['city']!;
  _sort(day.items);
  TripItem? prev;
  for (final it in day.items) {
    if (it.status == BookingStatus.cancelled) {
      it.travel = null;
      continue;
    }
    if (it.kind == ItemKind.arrive) {
      it.travel = null;
      it.dist = null;
      prev = it;
      continue;
    }
    final fLat = prev?.lat ?? hotel.lat, fLng = prev?.lng ?? hotel.lng;
    it.dist = haversine(fLat, fLng, it.lat, it.lng);
    it.travel = travelMinutes(fLat, fLng, it.lat, it.lng, p.transport);
    prev = it;
  }
}

List<TripItem> specialItems(Trip trip, int di) {
  final p = trip.prefs, n = trip.days.length;
  final hotel = hotels[p.hotel] ?? hotels['city']!;
  final out = <TripItem>[];
  if (di == 0) {
    out.add(TripItem(uid: newUid(), kind: ItemKind.arrive, start: p.arriveT, end: p.arriveT + 120,
        lat: hotel.lat, lng: hotel.lng, kept: true, status: BookingStatus.info));
  }
  if (di == n - 1) {
    out.add(TripItem(uid: newUid(), kind: ItemKind.depart, start: p.departT - 180, end: p.departT,
        lat: kwi.lat, lng: kwi.lng, kept: true, status: BookingStatus.info));
  }
  return out;
}

Trip makeTrip(Prefs p, Set<String> hidden) {
  final days = <TripDay>[];
  var d = p.arrive;
  while (d.compareTo(p.depart) <= 0 && days.length < 14) {
    days.add(TripDay(d));
    d = addDays(d, 1);
  }
  final trip = Trip(p, days);
  for (var i = 0; i < days.length; i++) {
    buildDay(trip, i, specialItems(trip, i), hidden);
  }
  return trip;
}

void rebuildDay(Trip trip, int di, Set<String> hidden, [String? pace]) {
  if (pace != null) trip.days[di].pace = pace;
  final keep = trip.days[di].items.where((i) => i.locked).toList();
  buildDay(trip, di, keep, hidden);
}

void rebuildAll(Trip trip, Set<String> hidden) {
  for (var i = 0; i < trip.days.length; i++) {
    rebuildDay(trip, i, hidden);
  }
}

/* ---------------- edits ---------------- */

class Alternative {
  final Listing c;
  final int start, end;
  final double s;
  final List<Why> why;
  final ItemKind kind;
  final String? meal, occ;
  final int? seats;
  Alternative(this.c, this.start, this.end, this.s, this.why, this.kind, {this.meal, this.occ, this.seats});
}

/// Options that fit exactly where item [uid] sits now.
List<Alternative> alternatives(Trip trip, int di, String uid, Set<String> hidden, {int limit = 5}) {
  final day = trip.days[di];
  final x = day.items.firstWhere((i) => i.uid == uid);
  final others = day.items.where((i) => i.uid != uid && i.status != BookingStatus.cancelled).toList();
  final ctx = makeCtx(trip, di, hidden, excludeUid: uid);
  final b = dayBounds(trip, di);
  final prev = prevOf(others, x.start);
  TripItem? next;
  for (final it in others) {
    if (it.start >= x.end && (next == null || it.start < next.start)) next = it;
  }
  final lo = prev?.end ?? b.s, hi = next?.start ?? b.e;
  final fLat = prev?.lat ?? ctx.hotel.lat, fLng = prev?.lng ?? ctx.hotel.lng;
  final res = <Alternative>[];
  if (x.kind == ItemKind.meal) {
    final dur = x.end - x.start;
    for (final c in places) {
      if (!c.isRestaurant || !c.meals.contains(x.meal) || c.id == x.ref) continue;
      final t = tryPlace(c, dur, others, ctx, b, math.max(lo, x.start - 60), math.min(hi, x.start + 60));
      if (t == null) continue;
      final sc = score(c, ctx, fLat, fLng, t);
      res.add(Alternative(c, t, t + dur, sc.s, sc.why, ItemKind.meal, meal: x.meal));
    }
  } else {
    for (final c in places) {
      if (c.id == x.ref || ctx.used.contains(c.id)) continue;
      if (c.isRestaurant && !c.meals.contains('s')) continue;
      final dur = c.isRestaurant ? 45 : c.dur;
      final t = tryPlace(c, dur, others, ctx, b, lo, hi - dur);
      if (t == null) continue;
      final sc = score(c, ctx, fLat, fLng, t);
      res.add(Alternative(c, t, t + dur, sc.s, sc.why, ItemKind.place));
    }
    for (final o in occurrencesOn(day.date)) {
      if (o.ev.id == x.ref || ctx.usedEv.contains(o.ev.id) || o.seats < trip.prefs.party) continue;
      if (!eligible(o.ev, ctx, o.start, o.end)) continue;
      if (!fitAt(others, o.start, o.end, o.ev.lat, o.ev.lng, ctx, b, true)) continue;
      final sc = score(o.ev, ctx, fLat, fLng, o.start);
      res.add(Alternative(o.ev, o.start, o.end, sc.s + .5, sc.why, ItemKind.event, occ: o.id, seats: o.seats));
    }
  }
  res.sort((a, c) => c.s.compareTo(a.s));
  return res.take(limit).toList();
}

TripItem applyAlternative(Trip trip, int di, String uid, Alternative a) {
  final day = trip.days[di];
  final i = day.items.indexWhere((z) => z.uid == uid);
  final it = _mk(a.kind, a.c, a.start, a.end, meal: a.meal, occ: a.occ, seats: a.seats, price: a.c.price, why: a.why);
  day.items[i] = it;
  finalize(trip, di);
  return it;
}

void removeItem(Trip trip, int di, String uid) {
  trip.days[di].items.removeWhere((i) => i.uid == uid);
  finalize(trip, di);
}

class AddResult {
  final bool ok;
  final String? reason; // noSlot | soldout | notOn | closed | season | already | conflictKept | unknown
  final TripItem? item;
  final List<TripItem> removed;
  const AddResult(this.ok, {this.reason, this.item, this.removed = const []});
}

AddResult addToDay(Trip trip, int di, String refId, Set<String> hidden, {String? occId}) {
  final c = catalog[refId];
  if (c == null) return const AddResult(false, reason: 'unknown');
  final day = trip.days[di];
  final ctx = makeCtx(trip, di, hidden);
  final b = dayBounds(trip, di);
  if (day.items.any((i) => i.ref == refId && i.status != BookingStatus.cancelled)) {
    return const AddResult(false, reason: 'already');
  }
  if (c.isEvent) {
    final list = occurrencesOn(day.date).where((z) => z.ev.id == refId && (occId == null || z.id == occId)).toList();
    if (list.isEmpty) return const AddResult(false, reason: 'notOn');
    final o = list.first;
    if (o.seats < trip.prefs.party) return const AddResult(false, reason: 'soldout');
    final blockers = day.items
        .where((i) => i.status != BookingStatus.cancelled && overlaps(o.start - 30, o.end + 30, i.start, i.end))
        .toList();
    if (blockers.any((i) => i.locked)) return const AddResult(false, reason: 'conflictKept');
    day.items.removeWhere(blockers.contains);
    final it = _mk(ItemKind.event, c, o.start, o.end, occ: o.id, seats: o.seats, price: c.price,
        why: score(c, ctx, ctx.hotel.lat, ctx.hotel.lng, o.start).why);
    day.items.add(it);
    final removed = [...blockers];
    for (var k = 0; k < 3; k++) {
      finalize(trip, di);
      TripItem? bad;
      for (var j = 1; j < day.items.length; j++) {
        final z = day.items[j];
        if (!z.locked && z != it && day.items[j - 1].end + (z.travel ?? 0) > z.start) {
          bad = z;
          break;
        }
      }
      if (bad == null) break;
      removed.add(bad);
      day.items.remove(bad);
    }
    finalize(trip, di);
    return AddResult(true, item: it, removed: removed);
  }
  final dur = c.isRestaurant && c.meals.contains('s') ? 45 : c.dur;
  final t = _tryManual(c, dur, day.items, ctx, b);
  if (t == null) {
    if (c.months != null && !c.months!.contains(ctx.month)) return const AddResult(false, reason: 'season');
    if (openWindows(c, day.date).isEmpty) return const AddResult(false, reason: 'closed');
    return const AddResult(false, reason: 'noSlot');
  }
  final kind = c.isRestaurant && dur != 45 ? ItemKind.meal : ItemKind.place;
  final meal = kind == ItemKind.meal ? (t < 660 ? 'b' : t < 960 ? 'l' : 'd') : null;
  final from = prevOf(day.items, t);
  final it = _mk(kind, c, t, t + dur, meal: meal, price: c.price,
      why: score(c, ctx, from?.lat ?? ctx.hotel.lat, from?.lng ?? ctx.hotel.lng, t).why);
  day.items.add(it);
  finalize(trip, di);
  return AddResult(true, item: it);
}

/// Manual adds: the visitor chose it, so skip budget/interest filters but keep hours and travel.
int? _tryManual(Listing c, int dur, List<TripItem> items, Ctx ctx, Bounds b) {
  for (final w in openWindows(c, ctx.date)) {
    var t = roundUp15(math.max(b.s, w[0]));
    for (; t + dur <= w[1] && t <= b.e - dur; t += 15) {
      if (ctx.hot && !c.indoor && overlaps(t, t + dur, 660, 1050)) continue;
      if (fitAt(items, t, t + dur, c.lat, c.lng, ctx, b, false)) return t;
    }
  }
  return null;
}

double tripCost(Trip trip) {
  var total = 0.0;
  for (final d in trip.days) {
    for (final it in d.items) {
      if (it.ref != null && it.status != BookingStatus.cancelled) {
        total += groupCost(catalog[it.ref]!, trip.prefs, it.price);
      }
    }
  }
  return total;
}
