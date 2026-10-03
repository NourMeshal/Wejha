import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../engine/planner.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class OnboardingScreen extends StatefulWidget {
  final Prefs? initial;
  const OnboardingScreen({super.key, this.initial});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late Prefs d;
  int step = 0;
  bool showTimes = false, moreInts = false, moreOpts = false, building = false;
  static const steps = 4;

  @override
  void initState() {
    super.initState();
    final start = addDays(dateStr(DateTime.now()), 14);
    d = widget.initial?.copy() ?? Prefs(arrive: start, depart: addDays(start, 3));
  }

  int get nDays => parseDate(d.depart).difference(parseDate(d.arrive)).inDays + 1;

  void setDays(int n) => setState(() => d.depart = addDays(d.arrive, n.clamp(1, 14) - 1));

  Future<void> pickArrival() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: parseDate(d.arrive),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      final n = nDays;
      setState(() {
        d.arrive = dateStr(picked);
        d.depart = addDays(d.arrive, n - 1);
      });
    }
  }

  Future<int?> pickTime(int current) async {
    final r = await showTimePicker(context: context, initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60));
    return r == null ? null : r.hour * 60 + r.minute;
  }

  Future<void> build_() async {
    final s = AppScope.of(context);
    setState(() => building = true);
    await Future.delayed(const Duration(milliseconds: 300));
    s.createTrip(d);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tt = Theme.of(context).textTheme;
    final titles = [('q1', 'q1s'), ('q2', ''), ('q3', 'q3s'), ('q4', '')];
    final blocked = step == 2 && d.interests.isEmpty;

    if (building) {
      return Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 18),
        Text(s.t('building'), style: tt.titleMedium),
      ])));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(step == 0 ? Icons.close : Icons.arrow_back),
          onPressed: () => step == 0 ? Navigator.pop(context) : setState(() => step--),
        ),
        title: LinearProgressIndicator(value: (step + 1) / steps, minHeight: 5, borderRadius: BorderRadius.circular(4)),
        actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('${step + 1} / $steps'))],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
              Text(s.t(titles[step].$1), style: tt.headlineMedium),
              if (titles[step].$2.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(s.t(titles[step].$2), style: tt.bodyLarge?.copyWith(color: VK.ink2)),
              ],
              const SizedBox(height: 24),
              ...switch (step) { 0 => _dates(s), 1 => _people(s), 2 => _interests(s), _ => _style(s) },
            ]),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(children: [
            Expanded(child: Text(blocked ? s.t('pickOne') : '', style: const TextStyle(color: VK.ink2))),
            FilledButton(
              onPressed: blocked ? null : () => step == steps - 1 ? build_() : setState(() => step++),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(step == steps - 1 ? s.t('build') : s.t('next')),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  /* ---------- step 1: dates ---------- */
  List<Widget> _dates(AppState s) => [
        _Tile(
          child: ListTile(
            leading: const Icon(Icons.event, color: VK.sea),
            title: Text(s.t('arrival')),
            subtitle: Text(s.date(d.arrive, long: true), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: VK.ink)),
            onTap: pickArrival,
          ),
        ),
        const SizedBox(height: 12),
        _Stepper(label: s.t('howDays'), value: nDays, min: 1, max: 14, onChanged: setDays),
        const SizedBox(height: 10),
        Text('${s.date(d.arrive, long: true)}  →  ${s.date(d.depart, long: true)}', style: const TextStyle(color: VK.ink2)),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(onPressed: () => setState(() => showTimes = !showTimes), child: Text(s.t('addTimes'))),
        ),
        if (showTimes)
          Row(children: [
            Expanded(
              child: _Tile(
                child: ListTile(
                  title: Text(s.t('landing')),
                  subtitle: Text(s.time(d.arriveT), style: const TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () async {
                    final v = await pickTime(d.arriveT);
                    if (v != null) setState(() => d.arriveT = v);
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Tile(
                child: ListTile(
                  title: Text(s.t('takeoff')),
                  subtitle: Text(s.time(d.departT), style: const TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () async {
                    final v = await pickTime(d.departT);
                    if (v != null) setState(() => d.departT = v);
                  },
                ),
              ),
            ),
          ]),
      ];

  /* ---------- step 2: people ---------- */
  List<Widget> _people(AppState s) => [
        _Stepper(label: s.t('adults'), sub: s.t('adultsS'), value: d.adults, min: 1, max: 12, onChanged: (v) => setState(() => d.adults = v)),
        const SizedBox(height: 12),
        _Stepper(
          label: s.t('children'),
          sub: s.t('childrenS'),
          value: d.kids,
          min: 0,
          max: 8,
          onChanged: (v) => setState(() {
            d.kids = v;
            if (v == 0) d.youngest = null;
          }),
        ),
        if (d.kids > 0) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<int?>(
            value: d.youngest,
            decoration: InputDecoration(labelText: s.t('youngest')),
            items: [
              DropdownMenuItem(value: null, child: Text(s.t('notSay'))),
              for (var a = 0; a <= 12; a++) DropdownMenuItem(value: a, child: Text('$a')),
            ],
            onChanged: (v) => setState(() => d.youngest = v),
          ),
        ],
      ];

  /* ---------- step 3: interests ---------- */
  List<Widget> _interests(AppState s) {
    final list = interests.where((i) => moreInts || i.main || d.interests.contains(i.id)).toList();
    return [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 180, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.15),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final it = list[i];
          final on = d.interests.contains(it.id);
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _toggle(d.interests, it.id)),
            child: Container(
              decoration: BoxDecoration(
                color: on ? VK.sea.withValues(alpha: .15) : VK.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: on ? VK.sea : Colors.transparent, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: ArtTile(it.motif)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(children: [
                    Expanded(child: Text(s.isAr ? it.ar : it.en, style: const TextStyle(fontWeight: FontWeight.w700))),
                    if (on) const Icon(Icons.check_circle, color: VK.sea, size: 20),
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
      const SizedBox(height: 10),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton(onPressed: () => setState(() => moreInts = !moreInts), child: Text(moreInts ? s.t('fewer') : s.t('moreInterests'))),
      ),
    ];
  }

  /* ---------- step 4: style ---------- */
  List<Widget> _style(AppState s) {
    final tt = Theme.of(context).textTheme;
    Widget choice(String label, String sub, bool on, VoidCallback tap) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: tap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: on ? VK.sea.withValues(alpha: .15) : VK.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: on ? VK.sea : Colors.transparent, width: 2),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                    Text(sub, style: const TextStyle(color: VK.ink2)),
                  ]),
                ),
                Icon(on ? Icons.radio_button_checked : Icons.radio_button_off, color: on ? VK.sea : VK.line),
              ]),
            ),
          ),
        );
    Widget chip(String label, bool on, VoidCallback tap) => FilterChip(
          label: Text(label),
          selected: on,
          onSelected: (_) => setState(tap),
          labelStyle: TextStyle(color: on ? VK.bg : VK.ink2, fontWeight: FontWeight.w600),
        );
    return [
      Text(s.t('paceL'), style: tt.titleMedium),
      const SizedBox(height: 8),
      for (final p in ['relaxed', 'balanced', 'busy']) choice(s.t(p), s.t('${p}S'), d.pace == p, () => setState(() => d.pace = p)),
      const SizedBox(height: 14),
      Text(s.t('budgetL'), style: tt.titleMedium),
      const SizedBox(height: 8),
      for (final b in ['economical', 'moderate', 'luxury'])
        choice(s.t(b), s.t('${b}S'), d.budget == b, () => setState(() => d.budget = b)),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton(onPressed: () => setState(() => moreOpts = !moreOpts), child: Text(s.t('moreOpts'))),
      ),
      if (moreOpts) ...[
        DropdownButtonFormField<String>(
          value: d.hotel,
          decoration: InputDecoration(labelText: s.t('hotel')),
          items: [for (final e in hotels.entries) DropdownMenuItem(value: e.key, child: Text(s.isAr ? e.value.ar : e.value.en))],
          onChanged: (v) => setState(() => d.hotel = v ?? 'city'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: d.transport,
          decoration: InputDecoration(labelText: s.t('transport')),
          items: [for (final m in ['taxi', 'car', 'walk', 'bus']) DropdownMenuItem(value: m, child: Text(s.t(m)))],
          onChanged: (v) => setState(() => d.transport = v ?? 'taxi'),
        ),
        const SizedBox(height: 16),
        Text(s.t('diet'), style: tt.titleSmall),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final x in ['vegetarian', 'vegan'])
            chip(s.t(x), d.diet.contains(x), () => _toggle(d.diet, x)),
        ]),
        const SizedBox(height: 16),
        Text(s.t('access'), style: tt.titleSmall),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: [
          chip(s.t('wheelchair'), d.access.contains('wheelchair'), () => _toggle(d.access, 'wheelchair')),
          chip(s.t('indoorPref'), d.indoor, () {
            d.indoor = !d.indoor;
          }),
        ]),
      ],
    ];
  }
}

void _toggle(List<String> list, String x) {
  if (list.contains(x)) {
    list.remove(x);
  } else {
    list.add(x);
  }
}

class _Tile extends StatelessWidget {
  final Widget child;
  const _Tile({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: VK.card, borderRadius: BorderRadius.circular(16)),
        child: child,
      );
}

class _Stepper extends StatelessWidget {
  final String label;
  final String? sub;
  final int value, min, max;
  final ValueChanged<int> onChanged;
  const _Stepper({required this.label, this.sub, required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _Tile(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              if (sub != null) Text(sub!, style: const TextStyle(color: VK.ink2)),
            ]),
          ),
          IconButton.outlined(onPressed: value > min ? () => onChanged(value - 1) : null, icon: const Icon(Icons.remove)),
          SizedBox(width: 44, child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
          IconButton.outlined(onPressed: value < max ? () => onChanged(value + 1) : null, icon: const Icon(Icons.add)),
        ]),
      ),
    );
  }
}
