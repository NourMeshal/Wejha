import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../engine/planner.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tt = Theme.of(context).textTheme;
    final favs = s.favorites.map((id) => catalog[id]).whereType<Listing>().toList();
    final partners = [
      ('Eventat', s.isAr ? 'حفلات ومسرحيات وفعاليات' : 'Concerts, plays and local events', false),
      ('The Arena Kuwait', s.isAr ? 'فعاليات ذا أرينا' : 'Events at The Arena', false),
      ('Cinescape', s.isAr ? 'مواعيد السينما' : 'Cinema showtimes', false),
      (s.isAr ? 'حجز المطاعم' : 'Restaurant booking', s.isAr ? 'طاولات المطاعم' : 'Restaurant tables', false),
      ('Google Maps', s.isAr ? 'الاتجاهات' : 'Directions', true),
    ];

    return PageBody(banner: false, children: [
      Text(s.t('profile'), style: tt.headlineMedium),
      const SizedBox(height: 16),
      _Section(children: [
        Text(s.t('language'), style: tt.titleMedium),
        const SizedBox(height: 10),
        SegmentedButton<String>(
          segments: const [ButtonSegment(value: 'en', label: Text('English')), ButtonSegment(value: 'ar', label: Text('العربية'))],
          selected: {s.lang},
          onSelectionChanged: (v) => s.setLang(v.first),
        ),
      ]),
      if (s.trip != null) ...[
        const SizedBox(height: 14),
        _Section(children: [
          Text(s.t('yourTrip'), style: tt.titleMedium),
          const SizedBox(height: 4),
          Text('${s.t('total')}: ${s.kwd(tripCost(s.trip!))}', style: const TextStyle(color: VK.ink2)),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => OnboardingScreen(initial: s.trip!.prefs)),
              ),
              child: Text(s.t('editPrefs')),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: VK.danger),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(s.t('resetQ')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.t('cancel'))),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.t('delete'))),
                    ],
                  ),
                );
                if (ok == true) s.deleteTrip();
              },
              child: Text(s.t('reset')),
            ),
          ]),
        ]),
      ],
      if (favs.isNotEmpty) ...[
        const SizedBox(height: 14),
        _Section(children: [
          Text(s.isAr ? 'المحفوظات' : 'Saved', style: tt.titleMedium),
          for (final c in favs)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ArtTile(c.motif, imageUrl: c.imageUrl, width: 48, height: 48, radius: BorderRadius.circular(10)),
              title: Text(s.name(c)),
              onTap: () => showDetails(context, c.id),
            ),
        ]),
      ],
      const SizedBox(height: 14),
      _Section(children: [
        Text(s.t('partners'), style: tt.titleMedium),
        const SizedBox(height: 4),
        Text(s.t('partnersS'), style: const TextStyle(color: VK.ink2)),
        const SizedBox(height: 8),
        for (final p in partners)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(p.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(p.$2),
            trailing: Pill(p.$3 ? s.t('linkOnly') : s.t('notConnected')),
          ),
      ]),
    ]);
  }
}

class _Section extends StatelessWidget {
  final List<Widget> children;
  const _Section({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: VK.card, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
}
