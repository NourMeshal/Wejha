import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../engine/planner.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';
import 'onboarding_screen.dart';

String? _catalogImageUrl(String id) => catalog[id]?.imageUrl;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tt = Theme.of(context).textTheme;
    final today = dateStr(DateTime.now());
    final upcoming = [for (var i = 0; i < 4; i++) ...occurrencesOn(addDays(today, i))]
        .where((o) => o.ev.cat != 'cinema')
        .take(10)
        .toList();

    final top = <Widget>[];
    if (s.trip == null) {
      top.addAll([
        const SizedBox(height: 8),
        Text(s.t('heroTitle'), style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w700, height: 1.2)),
        const SizedBox(height: 12),
        Text(s.t('heroSub'), style: tt.bodyLarge?.copyWith(color: VK.ink2, fontSize: 18)),
        const SizedBox(height: 22),
        Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingScreen())),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(s.t('planTrip'))),
          ),
          OutlinedButton(onPressed: () => s.setTab(1), child: Text(s.t('browse'))),
        ]),
      ]);
    } else {
      final events = <(int, TripItem)>[
        for (var i = 0; i < s.trip!.days.length; i++)
          for (final it in s.trip!.days[i].items)
            if (it.kind == ItemKind.event) (i, it)
      ];
      top.addAll([
        Text(s.t('yourTrip'), style: tt.headlineMedium),
        const SizedBox(height: 4),
        Text('${s.date(s.trip!.prefs.arrive, long: true)} – ${s.date(s.trip!.prefs.depart, long: true)}', style: const TextStyle(color: VK.ink2)),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => s.setTab(2), child: Text(s.t('myTrip'))),
        const SizedBox(height: 24),
        for (final (di, it) in events.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Row(
              motif: catalogMotif(it.ref!),
              imageUrl: _catalogImageUrl(it.ref!),
              title: s.itemTitle(it),
              sub: '${s.date(s.trip!.days[di].date)}, ${s.time(it.start)}',
              onTap: () {
                s.selectDay(di);
                s.selectItem(it.uid);
                s.setTab(2);
              },
            ),
          ),
      ]);
    }

    return PageBody(children: [
      ...top,
      const SizedBox(height: 28),
      Text(s.t('onThisWeek'), style: tt.titleLarge),
      const SizedBox(height: 12),
      for (final o in upcoming)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _Row(
            motif: o.ev.motif,
            imageUrl: o.ev.imageUrl,
            title: s.name(o.ev),
            sub: '${s.date(o.date)}, ${s.time(o.start)}${o.seats == 0 ? ', ${s.t('soldOut')}' : ''}',
            onTap: () => showDetails(context, o.ev.id, occId: o.id),
          ),
        ),
    ]);
  }
}

String catalogMotif(String id) => catalog[id]!.motif;

class _Row extends StatelessWidget {
  final String motif;
  final String? imageUrl;
  final String title, sub;
  final VoidCallback onTap;
  const _Row({required this.motif, this.imageUrl, required this.title, required this.sub, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: VK.card,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(children: [
            ArtTile(motif, imageUrl: imageUrl, width: 88, height: 88),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 3),
                Text(sub, style: const TextStyle(color: VK.ink2, fontSize: 13)),
              ]),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.chevron_right, color: VK.ink2)),
          ]),
        ),
      );
}
