import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'common.dart';
import 'sheets.dart';

/// One stop in the day. Kept deliberately simple:
/// name, time, place, price, one reason, and three buttons.
class ActivityCard extends StatelessWidget {
  final int dayIndex;
  final TripItem item;
  const ActivityCard({super.key, required this.dayIndex, required this.item});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tt = Theme.of(context).textTheme;
    final it = item;
    final selected = s.selItem == it.uid;
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: selected ? VK.sea : Colors.transparent, width: 2),
    );

    // Arrival, departure and hotel rest: simple text cards.
    if (it.ref == null) {
      final (title, sub) = switch (it.kind) {
        ItemKind.arrive => (s.t('arriveTitle'), s.t('arriveSub')),
        ItemKind.depart => (s.t('departTitle'), s.t('departSub')),
        _ => (s.t('restTitle'), s.t('restSub')),
      };
      return Card(
        shape: border,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: tt.titleMedium),
                Text(sub, style: tt.bodyMedium?.copyWith(color: VK.ink2)),
              ]),
            ),
            if (it.kind == ItemKind.hotelBreak)
              TextButton(onPressed: () => s.remove(dayIndex, it.uid), child: Text(s.t('remove'))),
          ]),
        ),
      );
    }

    final c = catalog[it.ref]!;
    final price = it.price ?? c.price;
    final place = c.isEvent ? venues[c.venue]!.name(s.lang) : s.area(c.area);
    final reason = it.why.where((w) => w.k == 'dated').firstOrNull ?? it.why.firstOrNull;

    return Card(
      shape: border,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => s.selectItem(it.uid),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 10, top: 10, bottom: 10),
              child: ArtTile(c.motif, imageUrl: c.imageUrl, width: 84, height: 84, radius: BorderRadius.circular(14)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(s.itemTitle(it), style: tt.titleMedium)),
                    if (it.kept && it.status != BookingStatus.confirmed) Pill(s.t('pinned')),
                    statusPill(s, it.status),
                  ]),
                  const SizedBox(height: 2),
                  Text('${s.time(it.start)} – ${s.time(it.end)}   $place', style: tt.bodyMedium?.copyWith(color: VK.ink2)),
                  const SizedBox(height: 2),
                  Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    Text.rich(TextSpan(children: [
                      TextSpan(text: s.kwd(price), style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (price > 0) TextSpan(text: ' ${s.t('perPerson')}'),
                    ])),
                    if (lowSeats(it)) Pill(s.t('seatsLeft', {'n': it.seats!}), bg: VK.saffronBg, fg: VK.saffron),
                    if (it.conf != null) Pill('#${it.conf}', bg: VK.ok.withValues(alpha: .14), fg: VK.ok),
                  ]),
                  if (reason != null) ...[
                    const SizedBox(height: 4),
                    Text(s.whyText(reason), style: tt.bodyMedium?.copyWith(color: VK.ink2)),
                  ],
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    if (price > 0 || c.isEvent)
                      FilledButton(
                        style: FilledButton.styleFrom(minimumSize: const Size(72, 44)),
                        onPressed: () => showBooking(context, dayIndex, it.uid),
                        child: Text(s.t('book')),
                      ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(72, 44)),
                      onPressed: () => showDetails(context, c.id, occId: it.occ, canAdd: false),
                      child: Text(s.t('details')),
                    ),
                    if (it.status != BookingStatus.confirmed) _ChangeMenu(dayIndex: dayIndex, item: it),
                  ]),
                ]),
              ),
            ),
          ]),
      ),
    );
  }
}

class _ChangeMenu extends StatelessWidget {
  final int dayIndex;
  final TripItem item;
  const _ChangeMenu({required this.dayIndex, required this.item});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return MenuAnchor(
      builder: (context, ctl, _) => OutlinedButton.icon(
        style: OutlinedButton.styleFrom(minimumSize: const Size(72, 44)),
        onPressed: () => ctl.isOpen ? ctl.close() : ctl.open(),
        icon: const Icon(Icons.swap_horiz, size: 18),
        label: Text(s.t('change')),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.autorenew),
          onPressed: () {
            final n = s.swap(dayIndex, item.uid);
            toast(context, n == null ? s.t('noAlt') : s.t('replaced', {'n': n}));
          },
          child: Text(s.t('swap')),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.list),
          onPressed: () => showAlternatives(context, dayIndex, item.uid),
          child: Text(s.t('options')),
        ),
        MenuItemButton(
          leadingIcon: Icon(item.kept ? Icons.push_pin : Icons.push_pin_outlined),
          onPressed: () => s.togglePin(dayIndex, item.uid),
          child: Text(item.kept ? s.t('unpin') : s.t('pin')),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.delete_outline, color: VK.danger),
          onPressed: () {
            s.remove(dayIndex, item.uid);
            toast(context, s.t('removed'));
          },
          child: Text(s.t('remove'), style: const TextStyle(color: VK.danger)),
        ),
      ],
    );
  }
}
