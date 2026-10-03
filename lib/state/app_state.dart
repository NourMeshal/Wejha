import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog.dart';
import '../engine/planner.dart';
import '../l10n/strings.dart';
import '../models/trip.dart';

class AppState extends ChangeNotifier {
  String lang = 'en';
  Trip? trip;
  int tab = 0; // 0 home, 1 discover, 2 my trip, 3 concierge, 4 profile
  int selDay = 0;
  String? selItem;
  final Set<String> favorites = {};
  final Set<String> hidden = {};
  final List<ChatMsg> chat = [];

  /* ---------- text ---------- */
  bool get isAr => lang == 'ar';
  String t(String key, [Map<String, Object>? vars]) {
    var s = strings[lang]?[key] ?? strings['en']![key] ?? key;
    vars?.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
    return s;
  }

  String name(Listing c) => c.name(lang);
  String area(String a) => isAr ? (areaAr[a] ?? a) : a;
  String interestName(String id) {
    final i = interests.where((x) => x.id == id);
    if (i.isEmpty) return id;
    return isAr ? i.first.ar : i.first.en;
  }

  String time(int m) {
    m = ((m % 1440) + 1440) % 1440;
    var hh = m ~/ 60;
    final mm = (m % 60).toString().padLeft(2, '0');
    final am = hh < 12;
    hh = hh % 12 == 0 ? 12 : hh % 12;
    return isAr ? '$hh:$mm ${am ? 'ص' : 'م'}' : '$hh:$mm ${am ? 'AM' : 'PM'}';
  }

  String date(String s, {bool long = false}) {
    final d = parseDate(s);
    final f = long ? DateFormat('EEEE d MMMM', isAr ? 'ar' : 'en') : DateFormat('EEE d MMM', isAr ? 'ar' : 'en');
    return f.format(d);
  }

  String weekdayShort(String s) => DateFormat('EEE', isAr ? 'ar' : 'en').format(parseDate(s));
  String dayMonth(String s) => DateFormat('d MMM', isAr ? 'ar' : 'en').format(parseDate(s));

  String kwd(double v) {
    if (v == 0) return t('free');
    final n = v.toStringAsFixed(3);
    return isAr ? '$n د.ك' : 'KWD $n';
  }

  String whyText(Why w) {
    switch (w.k) {
      case 'match':
        return t('why_match', {'v': w.v.map(interestName).join(isAr ? ' و' : ', ')});
      case 'near':
        return t('why_near', {'v': (w.d ?? 0).toStringAsFixed(1)});
      default:
        return t('why_${w.k}');
    }
  }

  String itemTitle(TripItem it) {
    switch (it.kind) {
      case ItemKind.arrive:
        return t('arriveTitle');
      case ItemKind.depart:
        return t('departTitle');
      case ItemKind.hotelBreak:
        return t('restTitle');
      case ItemKind.meal:
        final meal = it.meal == 'b' ? t('breakfast') : it.meal == 'l' ? t('lunch') : t('dinner');
        return '$meal: ${name(catalog[it.ref]!)}';
      default:
        return name(catalog[it.ref]!);
    }
  }

  /* ---------- actions ---------- */
  void setLang(String l) {
    lang = l;
    _changed();
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  void createTrip(Prefs p) {
    trip = makeTrip(p, hidden);
    selDay = 0;
    selItem = null;
    chat.clear();
    tab = 2;
    _changed();
  }

  void deleteTrip() {
    trip = null;
    chat.clear();
    tab = 0;
    _changed();
  }

  void selectDay(int i) {
    selDay = i;
    selItem = null;
    notifyListeners();
  }

  void selectItem(String? uid) {
    selItem = uid;
    notifyListeners();
  }

  void togglePin(int di, String uid) {
    final it = trip!.days[di].items.firstWhere((i) => i.uid == uid);
    it.kept = !it.kept;
    _changed();
  }

  void remove(int di, String uid) {
    removeItem(trip!, di, uid);
    _changed();
  }

  /// Returns the new name, or null if nothing fits.
  String? swap(int di, String uid) {
    final alts = alternatives(trip!, di, uid, hidden, limit: 1);
    if (alts.isEmpty) return null;
    final it = applyAlternative(trip!, di, uid, alts.first);
    selItem = it.uid;
    _changed();
    return name(alts.first.c);
  }

  void useAlternative(int di, String uid, Alternative a) {
    final it = applyAlternative(trip!, di, uid, a);
    selItem = it.uid;
    _changed();
  }

  void setDayPace(int di, String pace) {
    rebuildDay(trip!, di, hidden, pace);
    _changed();
  }

  void refreshTrip() {
    rebuildAll(trip!, hidden);
    _changed();
  }

  AddResult add(int di, String id, {String? occId}) {
    final r = addToDay(trip!, di, id, hidden, occId: occId);
    if (r.ok) {
      selDay = di;
      selItem = r.item!.uid;
      _changed();
    }
    return r;
  }

  void confirmBooking(int di, String uid, String conf) {
    final it = trip!.days[di].items.firstWhere((i) => i.uid == uid);
    it.conf = conf;
    it.status = BookingStatus.confirmed;
    it.kept = true;
    _changed();
  }

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    _changed();
  }

  void notify() => _changed();

  /* ---------- persistence ---------- */
  static const _key = 'visit_kuwait_v1';

  Future<void> load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_key);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      lang = j['lang'] ?? 'en';
      if (j['trip'] != null) trip = Trip.fromJson(Map<String, dynamic>.from(j['trip']));
      favorites.addAll(List<String>.from(j['favorites'] ?? []));
      hidden.addAll(List<String>.from(j['hidden'] ?? []));
    } catch (_) {
      trip = null; // corrupted or old format: start fresh
    }
  }

  Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_key, jsonEncode({
        'lang': lang,
        'trip': trip?.toJson(),
        'favorites': favorites.toList(),
        'hidden': hidden.toList(),
      }));
    } catch (_) {}
  }

  void _changed() {
    notifyListeners();
    _save();
  }
}

class ChatMsg {
  final bool fromUser;
  final String text;
  final List<String> changes;
  ChatMsg(this.fromUser, this.text, [this.changes = const []]);
}

/// Gives every widget access to the state: `AppScope.of(context)`.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);
  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
