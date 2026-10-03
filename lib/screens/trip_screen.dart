import 'package:flutter/material.dart';

import '../engine/planner.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/activity_card.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';
import '../widgets/trip_map.dart';
import 'onboarding_screen.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});
  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  bool showMap = true;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tt = Theme.of(context).textTheme;
    final trip = s.trip;
    if (trip == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s.t('noTrip'), style: tt.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingScreen())),
                child: Text(s.t('planTrip')),
              ),
            ],
          ),
        ),
      );
    }
    final di = s.selDay.clamp(0, trip.days.length - 1);
    final day = trip.days[di];
    final p = trip.prefs;
    final month = monthOf(day.date);
    final hot = climateHighs[month - 1] >= 38;
    final wide = MediaQuery.sizeOf(context).width >= 1000;

    final header = [
      Text('${s.t('days', {'n': trip.days.length})}, ${s.t('adultsN', {'n': p.adults})}${p.kids > 0 ? ', ${s.t('kidsN', {'n': p.kids})}' : ''}',
          style: const TextStyle(color: VK.ink2)),
      Text(s.t('yourTrip'), style: tt.headlineMedium),
      const SizedBox(height: 12),
      SizedBox(
        height: 64,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: trip.days.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final on = i == di;
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => s.selectDay(i),
              child: Container(
                width: 88,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: on ? VK.sea : VK.card, borderRadius: BorderRadius.circular(14)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(s.weekdayShort(trip.days[i].date), style: TextStyle(fontWeight: FontWeight.w700, color: on ? VK.bg : VK.ink)),
                  Text(s.dayMonth(trip.days[i].date), style: TextStyle(fontSize: 13, color: on ? VK.bg.withValues(alpha: .7) : VK.ink2)),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(
          child: Text('${s.t('typical', {'n': climateHighs[month - 1]})}${hot ? ' ${s.t('hot')}' : ''}',
              style: const TextStyle(color: VK.ink2, fontSize: 14)),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size(60, 44)),
          onPressed: () => showAdjustDay(context, di),
          child: Text(s.t('adjustDay')),
        ),
      ]),
    ];

    final timeline = <Widget>[];
    for (final it in day.items) {
      if (it.status == BookingStatus.cancelled && it.conf == null) continue;
      if ((it.travel ?? 0) > 0) timeline.add(_Leg(item: it, mode: p.transport));
      timeline.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 72,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(s.time(it.start), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
          Expanded(child: ActivityCard(dayIndex: di, item: it)),
        ]),
      ));
    }

    if (wide) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: PageBody(children: [...header, const SizedBox(height: 16), ...timeline])),
        SizedBox(
          width: 420,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 18, 16),
            child: TripMap(dayIndex: di, height: 480),
          ),
        ),
      ]);
    }
    return PageBody(children: [
      ...header,
      const SizedBox(height: 10),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: () => setState(() => showMap = !showMap),
          icon: Icon(showMap ? Icons.map : Icons.map_outlined),
          label: Text(showMap ? s.t('hideMap') : s.t('showMap')),
        ),
      ),
      if (showMap) ...[TripMap(dayIndex: di, height: 230), const SizedBox(height: 16)],
      ...timeline,
    ]);
  }
}

class _Leg extends StatelessWidget {
  final TripItem item;
  final String mode;
  const _Leg({required this.item, required this.mode});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final walking = mode == 'walk' && (item.dist ?? 9) < 1.5;
    final txt = walking
        ? s.t('byWalk', {'m': item.travel!})
        : mode == 'bus'
            ? s.t('byBus', {'m': item.travel!})
            : s.t('byTaxi', {'m': item.travel!, 'k': (item.dist ?? 0).toStringAsFixed(1)});
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 80, top: 4, bottom: 8),
      child: Row(children: [
        Icon(walking ? Icons.directions_walk : mode == 'bus' ? Icons.directions_bus : Icons.local_taxi, size: 16, color: VK.ink2),
        const SizedBox(width: 6),
        Text(txt, style: const TextStyle(color: VK.ink2, fontSize: 13)),
      ]),
    );
  }
}
