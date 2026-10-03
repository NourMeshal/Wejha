import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/catalog.dart';
import '../engine/planner.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'common.dart';

Future<void> _open(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String mapsUrl(double lat, double lng) => 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

/* ─── Photo hero ─────────────────────────────────────────────────────────── */
/// Full-width hero at the top of the detail sheet.
/// Shows a swipeable PageView when [photos] are provided (restaurants),
/// or a single image for events/places. Overlays logo badge + drag handle.
class _PhotoHero extends StatefulWidget {
  final Listing c;
  const _PhotoHero(this.c);
  @override
  State<_PhotoHero> createState() => _PhotoHeroState();
}

class _PhotoHeroState extends State<_PhotoHero> {
  late final PageController _ctrl;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final slides = [if (c.imageUrl != null) c.imageUrl!, ...c.photos];

    Widget imageAt(String url) => Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => ArtTile(c.motif, height: 240),
        );

    final heroContent = slides.isEmpty
        ? ArtTile(c.motif, height: 200)
        : slides.length == 1
            ? imageAt(slides[0])
            : PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: slides.length,
                itemBuilder: (_, i) => imageAt(slides[i]),
              );

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SizedBox(height: 240, child: heroContent),
        ),

        // drag handle pill
        Positioned(
          top: 10, left: 0, right: 0,
          child: Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),

        // restaurant logo badge
        if (c.logoUrl != null)
          Positioned(
            bottom: slides.length > 1 ? 28 : 12,
            left: 14,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 90, maxHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.20), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Image.network(
                c.logoUrl!,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

        // dot indicators
        if (slides.length > 1)
          Positioned(
            bottom: 12, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _page == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _page == i ? Colors.white : Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),
      ],
    );
  }
}

Future<T?> _sheet<T>(BuildContext context, Widget Function(BuildContext) builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * .88),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(ctx).bottom),
          child: builder(ctx),
        ),
      ),
    ),
  );
}

/* ---------- details ---------- */
Future<void> showDetails(BuildContext context, String id, {String? occId, bool canAdd = true}) {
  final s = AppScope.of(context);
  final c = catalog[id]!;
  final Occurrence? occ = occId == null
      ? null
      : occurrencesOn(occId.split('@')[1]).where((o) => o.id == occId).firstOrNull;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) {
      final tt = Theme.of(ctx).textTheme;
      final rows = <(String, String)>[
        (c.isEvent ? (s.isAr ? 'المكان' : 'Venue') : (s.isAr ? 'المنطقة' : 'Area'),
            c.isEvent ? venues[c.venue]!.name(s.lang) : s.area(c.area)),
        if (occ != null) (s.isAr ? 'الموعد' : 'When', '${s.date(occ.date)}, ${s.time(occ.start)} – ${s.time(occ.end)}'),
        if (occ != null) (s.isAr ? 'التوفر' : 'Availability', occ.seats > 0 ? s.t('seatsLeft', {'n': occ.seats}) : s.t('soldOut')),
        (s.isAr ? 'المدة' : 'Duration', '${c.dur} ${s.isAr ? 'دقيقة' : 'min'}'),
        (s.isAr ? 'السعر' : 'Price', '${s.kwd(c.price)} ${c.price > 0 ? s.t('perPerson') : ''}'),
        (s.isAr ? 'العمر' : 'Age', c.minAge > 0 ? '${c.minAge}+' : (s.isAr ? 'لكل الأعمار' : 'All ages')),
        if (c.lang.isNotEmpty) (s.isAr ? 'اللغة' : 'Language', c.lang),
      ];

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * .88),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero image / photo gallery ────────────────────────────
              _PhotoHero(c),

              // ── Scrollable body ───────────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.viewInsetsOf(ctx).bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(s.name(c), style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(c.description(s.lang), style: tt.bodyLarge?.copyWith(color: VK.ink2)),
                      const SizedBox(height: 14),
                      for (final r in rows)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(width: 110, child: Text(r.$1, style: const TextStyle(color: VK.ink2))),
                            Expanded(child: Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w600))),
                          ]),
                        ),
                      const SizedBox(height: 16),
                      Wrap(spacing: 10, runSpacing: 10, children: [
                        if (canAdd && s.trip != null)
                          FilledButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await showAddToTrip(context, id, occId: occId);
                            },
                            child: Text(s.t('addToTrip')),
                          ),
                        if (c.menuUrl != null)
                          OutlinedButton.icon(
                            onPressed: () => _open(c.menuUrl!),
                            icon: const Icon(Icons.menu_book_outlined),
                            label: Text(s.t('viewMenu')),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => _open(mapsUrl(c.lat, c.lng)),
                          icon: const Icon(Icons.directions),
                          label: Text(s.t('directions')),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            s.toggleFavorite(id);
                            Navigator.pop(ctx);
                          },
                          icon: Icon(s.favorites.contains(id) ? Icons.favorite : Icons.favorite_border),
                          label: Text(s.isAr ? 'احفظ' : 'Save'),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/* ---------- booking ---------- */
Future<void> showBooking(BuildContext context, int di, String uid) {
  final s = AppScope.of(context);
  final it = s.trip!.days[di].items.firstWhere((i) => i.uid == uid);
  final c = catalog[it.ref]!;
  final ctrl = TextEditingController(text: it.conf ?? '');
  final prov = c.provider != null ? providers[c.provider] : null;
  return _sheet(context, (ctx) {
    final tt = Theme.of(ctx).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(s.t('bookTitle', {'n': s.name(c)}), style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Text(s.t('bookNotLinked'), style: tt.bodyLarge),
      const SizedBox(height: 4),
      Text(s.t('bookHow'), style: tt.bodyMedium?.copyWith(color: VK.ink2)),
      const SizedBox(height: 16),
      if (prov != null)
        FilledButton.icon(
          onPressed: () => _open(prov.url),
          icon: const Icon(Icons.open_in_new),
          label: Text(s.t('openSite', {'p': prov.name})),
        )
      else
        FilledButton.icon(
          onPressed: () => _open('https://www.google.com/maps/search/?api=1&query=${c.lat},${c.lng}'),
          icon: const Icon(Icons.open_in_new),
          label: Text(s.isAr ? 'افتح في خرائط Google' : 'Open in Google Maps'),
        ),
      const SizedBox(height: 18),
      TextField(controller: ctrl, decoration: InputDecoration(labelText: s.t('confNo'))),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: () {
          final v = ctrl.text.trim();
          if (v.isNotEmpty) s.confirmBooking(di, uid, v);
          Navigator.pop(ctx);
        },
        child: Text(s.t('saveConf')),
      ),
    ]);
  });
}

/* ---------- alternatives ---------- */
Future<void> showAlternatives(BuildContext context, int di, String uid) {
  final s = AppScope.of(context);
  final alts = alternatives(s.trip!, di, uid, s.hidden, limit: 5);
  return _sheet(context, (ctx) {
    final tt = Theme.of(ctx).textTheme;
    if (alts.isEmpty) return Padding(padding: const EdgeInsets.all(12), child: Text(s.t('noAlt'), style: tt.bodyLarge));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(s.t('options'), style: tt.titleLarge),
      const SizedBox(height: 12),
      for (final a in alts)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: VK.line), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              ArtTile(a.c.motif, imageUrl: a.c.imageUrl, width: 56, height: 56, radius: BorderRadius.circular(12)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name(a.c), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('${s.time(a.start)} – ${s.time(a.end)}, ${s.kwd(a.c.price)}', style: const TextStyle(color: VK.ink2)),
                ]),
              ),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
                onPressed: () {
                  s.useAlternative(di, uid, a);
                  Navigator.pop(ctx);
                },
                child: Text(s.t('use')),
              ),
            ]),
          ),
        ),
    ]);
  });
}

/* ---------- adjust day ---------- */
Future<void> showAdjustDay(BuildContext context, int di) {
  final s = AppScope.of(context);
  final current = dayPace(s.trip!, di);
  return _sheet(context, (ctx) {
    final tt = Theme.of(ctx).textTheme;
    Widget opt(String pace, String label) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: current == pace ? VK.sea : VK.line, width: current == pace ? 2 : 1),
            ),
            tileColor: current == pace ? VK.sea.withValues(alpha: .08) : null,
            title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(s.t('${pace}S')),
            onTap: () {
              s.setDayPace(di, pace);
              Navigator.pop(ctx);
              toast(context, s.t('rebuilt'));
            },
          ),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(s.date(s.trip!.days[di].date, long: true), style: tt.titleLarge),
      const SizedBox(height: 12),
      opt('relaxed', s.t('lighter')),
      opt('balanced', s.t('balanced')),
      opt('busy', s.t('fuller')),
      Text(s.t('keptStay'), style: const TextStyle(color: VK.ink2)),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () {
          s.refreshTrip();
          Navigator.pop(ctx);
        },
        child: Text(s.t('refreshTrip')),
      ),
    ]);
  });
}

/* ---------- add to trip ---------- */
Future<void> showAddToTrip(BuildContext context, String id, {String? occId}) {
  final s = AppScope.of(context);
  final trip = s.trip!;
  final c = catalog[id]!;
  final dayIdx = <int>[
    for (var i = 0; i < trip.days.length; i++)
      if (!c.isEvent || occurrencesOn(trip.days[i].date).any((o) => o.ev.id == id)) i
  ];
  return _sheet(context, (ctx) {
    final tt = Theme.of(ctx).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(s.t('chooseDay'), style: tt.titleLarge),
      const SizedBox(height: 12),
      if (dayIdx.isEmpty) Text(s.t('r_notOn')),
      for (final i in dayIdx)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: OutlinedButton(
            onPressed: () {
              final d = trip.days[i].date;
              final oid = occId != null && occId.contains('@$d@') ? occId : null;
              final r = s.add(i, id, occId: oid);
              Navigator.pop(ctx);
              toast(context, r.ok ? s.t('added', {'d': s.date(d)}) : s.t('r_${r.reason}'));
            },
            child: Text(s.date(trip.days[i].date, long: true)),
          ),
        ),
    ]);
  });
}

/// Used by trip cards to show seat warnings, etc.
bool lowSeats(TripItem it) => it.kind == ItemKind.event && (it.seats ?? 99) < 20;
