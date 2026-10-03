import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../engine/planner.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// v0.1: understands simple requests on the phone.
/// v0.2: send the request to YOUR backend, which calls the AI model and returns
/// a list of actions. Never put an AI API key inside the app.
class ConciergeScreen extends StatefulWidget {
  const ConciergeScreen({super.key});
  @override
  State<ConciergeScreen> createState() => _ConciergeScreenState();
}

class _ConciergeScreenState extends State<ConciergeScreen> {
  final ctrl = TextEditingController();
  final scroll = ScrollController();

  int? _findDay(AppState s, String q) {
    const en = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    const ar = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    for (var w = 0; w < 7; w++) {
      if (q.contains(en[w]) || q.contains(ar[w])) {
        final i = s.trip!.days.indexWhere((d) => weekday(d.date) == w);
        if (i >= 0) return i;
      }
    }
    final m = RegExp(r'day\s*(\d+)').firstMatch(q);
    if (m != null) {
      final i = int.parse(m.group(1)!) - 1;
      if (i >= 0 && i < s.trip!.days.length) return i;
    }
    return null;
  }

  void _send(String text) {
    final s = AppScope.of(context);
    text = text.trim();
    if (text.isEmpty || s.trip == null) return;
    final q = text.toLowerCase();
    final trip = s.trip!;
    final day = _findDay(s, q) ?? s.selDay;
    final changes = <String>[];
    var reply = '';

    if (RegExp(r'relax|calm|slow|lighter|هاد|أهدأ|أخف').hasMatch(q)) {
      rebuildDay(trip, day, s.hidden, 'relaxed');
      changes.add('${s.date(trip.days[day].date)}: ${s.t('relaxed')}');
      reply = s.isAr ? 'خففت ذلك اليوم.' : 'I made that day lighter.';
    } else if (RegExp(r'busier|fuller|more things|مزدحم').hasMatch(q)) {
      rebuildDay(trip, day, s.hidden, 'busy');
      changes.add('${s.date(trip.days[day].date)}: ${s.t('busy')}');
      reply = s.isAr ? 'أضفت المزيد لذلك اليوم.' : 'I fitted more into that day.';
    }
    if (RegExp(r'cheap|budget|less expensive|أرخص|ميزانية').hasMatch(q)) {
      const order = ['economical', 'moderate', 'premium', 'luxury'];
      final i = order.indexOf(trip.prefs.budget);
      trip.prefs.budget = order[(i - 1).clamp(0, 3)];
      trip.prefs.customBudget = null;
      rebuildAll(trip, s.hidden);
      changes.add('${s.t('budgetL')}: ${s.t(trip.prefs.budget)}');
      reply = s.isAr ? 'خفضت سقف الإنفاق وحدّثت ما لم تثبته.' : 'I lowered the spend limit and updated anything you have not pinned.';
    }
    if (RegExp(r'kuwaiti|local|كويتي').hasMatch(q)) {
      for (final x in ['culture', 'heritage', 'kuwaiti_food', 'markets']) {
        if (!trip.prefs.interests.contains(x)) trip.prefs.interests.add(x);
      }
      rebuildAll(trip, s.hidden);
      changes.add(s.isAr ? 'أولوية للتجارب الكويتية' : 'Kuwaiti experiences first');
      reply = s.isAr ? 'قدّمت التجارب الكويتية.' : 'I put Kuwaiti experiences first.';
    }
    if (RegExp(r'kid|child|famil|أطفال|عائل').hasMatch(q)) {
      for (final x in ['family', 'kids']) {
        if (!trip.prefs.interests.contains(x)) trip.prefs.interests.add(x);
      }
      rebuildAll(trip, s.hidden);
      changes.add(s.isAr ? 'أنشطة للأطفال' : 'More for children');
      reply = s.isAr ? 'أضفت أنشطة للأطفال.' : 'I added things for the children.';
    }
    if (RegExp(r'indoor|inside|داخل').hasMatch(q)) {
      trip.prefs.indoor = true;
      rebuildDay(trip, day, s.hidden);
      changes.add(s.isAr ? 'أنشطة داخلية' : 'Indoor only');
      reply = s.isAr ? 'أبقيت الأنشطة داخلية.' : 'I kept things indoors.';
    }
    if (RegExp(r"(no|don'?t|skip|without).{0,20}shop|بدون تسوق|لا أريد التسوق").hasMatch(q)) {
      trip.prefs.interests.removeWhere((x) => ['shopping', 'luxury', 'markets'].contains(x));
      for (var i = 0; i < trip.days.length; i++) {
        trip.days[i].items.removeWhere((it) => !it.locked && it.kind == ItemKind.place && it.ref != null &&
            ['shopping', 'markets'].contains(_cat(it.ref!)));
      }
      rebuildAll(trip, s.hidden);
      changes.add(s.isAr ? 'أزيل التسوق' : 'Shopping removed');
      reply = s.isAr ? 'أزلت التسوق وملأت الوقت.' : 'I took shopping out and filled the time.';
    }

    s.chat.add(ChatMsg(true, text));
    s.chat.add(ChatMsg(false, reply.isEmpty ? '${s.t('notUnderstood')}\n\n${s.t('aiLater')}' : reply, changes));
    ctrl.clear();
    s.notify();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.animateTo(scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  String _cat(String id) => catalog[id]?.cat ?? '';

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tt = Theme.of(context).textTheme;
    if (s.trip == null) {
      return PageBody(children: [Text(s.t('concierge'), style: tt.headlineMedium), const SizedBox(height: 8), Text(s.t('planFirst'))]);
    }
    final sugs = s.isAr
        ? ['اجعل السبت أهدأ', 'اجعل الرحلة أرخص', 'تجارب كويتية أكثر', 'شيء للأطفال']
        : ['Make Saturday more relaxing', 'Make the trip cheaper', 'More Kuwaiti experiences', 'Something for the kids'];
    return Column(children: [
      Expanded(
        child: ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(18, 16, 18, 16), children: [
          Text(s.t('concierge'), style: tt.headlineMedium),
          const SizedBox(height: 6),
          Text(s.t('conciergeIntro'), style: tt.bodyLarge?.copyWith(color: VK.ink2)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final x in sugs) ActionChip(label: Text(x), onPressed: () => _send(x))]),
          const SizedBox(height: 18),
          for (final m in s.chat) _Bubble(m),
        ]),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                decoration: InputDecoration(hintText: s.t('askHint')),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: () => _send(ctrl.text), icon: const Icon(Icons.send), tooltip: s.t('send')),
          ]),
        ),
      ),
    ]);
  }
}

class _Bubble extends StatelessWidget {
  final ChatMsg m;
  const _Bubble(this.m);
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Align(
      alignment: m.fromUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(color: m.fromUser ? VK.sea : VK.card, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.text, style: TextStyle(color: m.fromUser ? VK.bg : VK.ink, fontSize: 16)),
          if (!m.fromUser && m.changes.isNotEmpty) ...[
            const Divider(height: 18),
            Text(s.t('didChanges'), style: const TextStyle(fontWeight: FontWeight.w700)),
            for (final c in m.changes) Text('✓ $c'),
          ],
        ]),
      ),
    );
  }
}
