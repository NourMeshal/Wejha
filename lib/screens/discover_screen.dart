import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../engine/planner.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String cat = 'all';
  String query = '';
  final ctrl = TextEditingController();

  static const _catTags = {
    'food': ['kuwaiti_food', 'fine_dining', 'cafes', 'desserts'],
    'culture': ['culture', 'heritage', 'museums', 'art', 'architecture'],
    'family': ['family', 'kids'],
    'shopping': ['shopping', 'luxury', 'markets'],
    'outdoor': ['beaches', 'desert', 'watersports', 'adventure'],
  };

  List<({Listing c, Occurrence? o})> _results(AppState s, {String? catOverride}) {
    final activeCat = catOverride ?? cat;
    final q = query.toLowerCase().trim();
    final dates = s.trip?.days.map((d) => d.date).toList() ??
        [for (var i = 0; i < 7; i++) addDays(dateStr(DateTime.now()), i)];
    final under = RegExp(r'(under|below|less than|أقل من)\s*(\d+(\.\d+)?)').firstMatch(q);
    final double? maxPrice = under == null ? null : double.tryParse(under.group(2)!);
    final indoor = q.contains('indoor') || q.contains('داخل');
    final kids = q.contains('kid') || q.contains('child') || q.contains('famil') || q.contains('أطفال');
    final tags = <String>[...?_catTags[activeCat]];
    for (final i in interests) {
      if (q.isNotEmpty && (q.contains(i.en.toLowerCase().split(' ').first) || q.contains(i.ar))) tags.add(i.id);
    }
    if (q.contains('concert') || q.contains('حفل')) tags.add('concerts');
    if (q.contains('play') || q.contains('مسرح')) tags.add('theatre');
    if (q.contains('movie') || q.contains('film') || q.contains('سينما')) tags.add('cinema');
    final words = q.split(RegExp(r'\s+')).where((w) => w.length > 3 && !RegExp(r'under|indoor|with|kids|this').hasMatch(w)).toList();

    bool ok(Listing c) {
      if (s.hidden.contains(c.id)) return false;
      if (tags.isNotEmpty && !c.tags.any(tags.contains)) return false;
      if (tags.isEmpty && words.isNotEmpty && !words.any((w) => '${c.en} ${c.ar} ${c.desc} ${c.area}'.toLowerCase().contains(w))) return false;
      if (maxPrice != null && c.price > maxPrice) return false;
      if (indoor && !c.indoor) return false;
      if (kids && !(c.tags.contains('family') || c.tags.contains('kids'))) return false;
      return true;
    }

    final out = <({Listing c, Occurrence? o})>[];
    final seen = <String>{};
    for (final d in dates) {
      for (final o in occurrencesOn(d)) {
        if (seen.contains(o.ev.id) || !ok(o.ev)) continue;
        seen.add(o.ev.id);
        out.add((c: o.ev, o: o));
      }
    }
    if (activeCat != 'events') {
      for (final c in places) {
        if (!ok(c)) continue;
        if (c.months != null && !dates.any((d) => c.months!.contains(monthOf(d)))) continue;
        out.add((c: c, o: null));
      }
    }
    return out;
  }

  Widget _card(BuildContext context, AppState s, ({Listing c, Occurrence? o}) r) {
    return GestureDetector(
      onTap: () => showDetails(context, r.c.id, occId: r.o?.id),
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: VK.card,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ArtTile(r.c.motif, imageUrl: r.c.imageUrl, width: 170, height: 100),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                s.name(r.c),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: VK.ink),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                r.o != null
                    ? s.t('nextOn', {'d': s.date(r.o!.date), 't': s.time(r.o!.start)})
                    : s.area(r.c.area),
                style: const TextStyle(color: VK.ink2, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (r.c.price > 0) ...[
                const SizedBox(height: 4),
                Text(s.kwd(r.c.price),
                    style: const TextStyle(color: VK.sea, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _horizontalList(BuildContext context, AppState s, List<({Listing c, Occurrence? o})> items) {
    return SizedBox(
      height: 215,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _card(context, s, items[i]),
      ),
    );
  }

  Widget _section(BuildContext context, AppState s, TextTheme tt, String catKey) {
    final items = _results(s, catOverride: catKey);
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(s.t(catKey), style: tt.titleMedium),
        TextButton(
          onPressed: () => setState(() => cat = catKey),
          style: TextButton.styleFrom(foregroundColor: VK.sea),
          child: Text(s.t('seeAll')),
        ),
      ]),
      const SizedBox(height: 10),
      _horizontalList(context, s, items),
      const SizedBox(height: 20),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tt = Theme.of(context).textTheme;
    const sectionCats = ['events', 'food', 'culture', 'family', 'shopping', 'outdoor'];
    final cats = ['all', ...sectionCats];
    final showSections = cat == 'all' && query.isEmpty;
    final res = showSections ? const <({Listing c, Occurrence? o})>[] : _results(s);

    return PageBody(children: [
      Text(s.t('discover'), style: tt.headlineMedium),
      const SizedBox(height: 12),
      TextField(
        controller: ctrl,
        textInputAction: TextInputAction.search,
        onSubmitted: (v) => setState(() => query = v),
        decoration: InputDecoration(
          hintText: s.t('searchHint'),
          prefixIcon: const Icon(Icons.search, color: VK.ink2),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, color: VK.ink2),
                  onPressed: () => setState(() {
                    query = '';
                    ctrl.clear();
                  }),
                ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => ChoiceChip(
            label: Text(s.t(cats[i])),
            selected: cat == cats[i],
            onSelected: (_) => setState(() {
              cat = cats[i];
              query = '';
              ctrl.clear();
            }),
          ),
        ),
      ),
      const SizedBox(height: 14),
      if (showSections)
        for (final catKey in sectionCats) _section(context, s, tt, catKey)
      else if (res.isEmpty)
        Text(s.t('noResults'), style: const TextStyle(color: VK.ink2))
      else
        _horizontalList(context, s, res),
    ]);
  }
}
