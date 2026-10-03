import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/concierge_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/trip_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

const _kSplashMs = 3800;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _SplashApp());
  final state = AppState();
  await Future.wait([
    initializeDateFormatting('en'),
    initializeDateFormatting('ar'),
    state.load(),
    Future.delayed(const Duration(milliseconds: _kSplashMs)),
  ]);
  runApp(AppScope(state: state, child: const WejhaApp()));
}

/* ─── Splash ─────────────────────────────────────────────────────────────── */

class _SplashApp extends StatefulWidget {
  const _SplashApp();
  @override
  State<_SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<_SplashApp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kSplashMs),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<T> _a<T>(Tween<T> tween, double t0, double t1,
          {Curve curve = Curves.easeInOut}) =>
      tween.animate(
          CurvedAnimation(parent: _ctrl, curve: Interval(t0, t1, curve: curve)));

  Animation<double> _fade(double t0, double t1,
          {Curve curve = Curves.easeInOut}) =>
      _a(Tween(begin: 0.0, end: 1.0), t0, t1, curve: curve);

  @override
  Widget build(BuildContext context) {
    final S = MediaQuery.sizeOf(context).shortestSide;
    final R = S * 0.30; // logo radius — kept compact

    // ── Phase timeline (fraction of _kSplashMs = 3800 ms) ────────────────
    //  0.00-0.10  spark blooms               →  380 ms
    //  0.08-0.45  arc draws clockwise        →  1404 ms
    //  0.38-0.62  logo fades / scales in     →  912 ms
    //  0.42-0.60  arc fades out              →  684 ms
    //  0.28-0.65  background glow rises      →  1406 ms
    //  0.62-0.92  plane flies arc            →  1140 ms
    //  0.88-0.98  plane fades out            →  380 ms
    //  0.90-1.00  logo gentle settle pulse   →  380 ms

    final sparkFade = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: ConstantTween(1.0),           weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.00, 0.12, curve: Curves.easeInOut)));

    final arcProgress = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.08, 0.45, curve: Curves.easeInOut));

    final arcFade = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(1.0),           weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.38, 0.62, curve: Curves.easeIn)));

    final bgGlow   = _fade(0.28, 0.65, curve: Curves.easeOut);
    final logoFade = _fade(0.38, 0.62, curve: Curves.easeOut);
    final logoScale = _a(Tween(begin: 0.75, end: 1.0), 0.38, 0.66,
        curve: Curves.easeOutBack);

    final planeProgress = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.62, 0.92, curve: Curves.easeInOut));
    final planeFade = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0),           weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.62, 0.98, curve: Curves.easeInOut)));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        backgroundColor: VK.bg,
        body: AnimatedBuilder(
          animation: _ctrl,
          builder: (ctx, _) => Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [

              // ── 1. Radial background bloom ──────────────────────────────
              Center(
                child: Opacity(
                  opacity: (bgGlow.value * 0.45).clamp(0.0, 1.0),
                  child: Container(
                    width: R * 5,
                    height: R * 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        VK.sea.withValues(alpha: 0.5),
                        VK.sea.withValues(alpha: 0.10),
                        Colors.transparent,
                      ], stops: const [0.0, 0.4, 1.0]),
                    ),
                  ),
                ),
              ),

              // ── 2. Arc painter ──────────────────────────────────────────
              Center(
                child: Opacity(
                  opacity: arcFade.value.clamp(0.0, 1.0),
                  child: CustomPaint(
                    size: Size(R * 2, R * 2),
                    painter: _ArcPainter(
                      progress: arcProgress.value,
                      radius: R * 0.78,
                    ),
                  ),
                ),
              ),

              // ── 3. Spark dot (leads the arc) ────────────────────────────
              Center(
                child: Opacity(
                  opacity: sparkFade.value.clamp(0.0, 1.0),
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: VK.sea.withValues(alpha: 0.9),
                            blurRadius: 30, spreadRadius: 12),
                        BoxShadow(color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 8,  spreadRadius: 2),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 4. Logo PNG ─────────────────────────────────────────────
              Center(
                child: Opacity(
                  opacity: logoFade.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: logoScale.value,
                    child: Image.asset(
                      'assets/images/logo_icon.png',
                      width: R * 2,
                      height: R * 2,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),

              // ── 5. Airplane ─────────────────────────────────────────────
              Center(
                child: Opacity(
                  opacity: planeFade.value.clamp(0.0, 1.0),
                  child: CustomPaint(
                    size: Size(R * 2, R * 2),
                    painter: _PlanePainter(
                      progress: planeProgress.value,
                      unitSize: R * 0.28,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

/* ─── Arc Painter ────────────────────────────────────────────────────────── */
/// Draws a glowing stroke that traces the circular ring of the Wejha pin,
/// with a bright comet-tip at the leading edge.
class _ArcPainter extends CustomPainter {
  final double progress;
  final double radius;
  const _ArcPainter({required this.progress, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final c   = Offset(size.width / 2, size.height / 2 - radius * 0.08);
    const s   = -math.pi * 0.70;   // start ~10 o'clock
    const tot =  math.pi * 1.72;   // sweep ~310°
    final sw  = tot * progress;
    final r   = Rect.fromCircle(center: c, radius: radius);

    // Outer diffuse glow
    canvas.drawArc(r, s, sw, false, Paint()
      ..color = VK.sea.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16));

    // Mid glow
    canvas.drawArc(r, s, sw, false, Paint()
      ..color = VK.sea.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // Core bright line
    canvas.drawArc(r, s, sw, false, Paint()
      ..color = const Color(0xFFB8EAED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round);

    // Comet tip at leading edge
    if (progress > 0.02) {
      final la = s + sw;
      final dx = c.dx + radius * math.cos(la);
      final dy = c.dy + radius * math.sin(la);
      canvas.drawCircle(Offset(dx, dy), 14, Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
      canvas.drawCircle(Offset(dx, dy), 6, Paint()
        ..color = Colors.white.withValues(alpha: 0.80)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawCircle(Offset(dx, dy), 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter o) =>
      o.progress != progress || o.radius != radius;
}

/* ─── Plane Painter ──────────────────────────────────────────────────────── */
/// Airplane on a cubic-bezier arc from lower-left to upper-right,
/// matching the logo's swoosh direction, with a fading teal trail.
class _PlanePainter extends CustomPainter {
  final double progress;
  final double unitSize;
  const _PlanePainter({required this.progress, required this.unitSize});

  Offset _b(Offset p0, Offset c1, Offset c2, Offset p3, double t) {
    final m = 1 - t;
    return Offset(
      m*m*m*p0.dx + 3*m*m*t*c1.dx + 3*m*t*t*c2.dx + t*t*t*p3.dx,
      m*m*m*p0.dy + 3*m*m*t*c1.dy + 3*m*t*t*c2.dy + t*t*t*p3.dy,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final w = size.width, h = size.height;

    // Bezier: lower-left → upper-right (mirrors the logo swoosh)
    final p0 = Offset(-w * 0.62,  h * 0.72);
    final c1 = Offset(-w * 0.10,  h * 0.44);
    final c2 = Offset( w * 0.28,  h * 0.04);
    final p3 = Offset( w * 0.85, -h * 0.32);

    // Trail — fades from transparent at tail to semi-opaque at tip
    final ts = math.max(0.0, progress - 0.45);
    for (var i = 1; i <= 36; i++) {
      final t0 = ts + (progress - ts) * (i - 1) / 36;
      final t1 = ts + (progress - ts) *  i      / 36;
      final a  = _b(p0, c1, c2, p3, t0);
      final b  = _b(p0, c1, c2, p3, t1);
      final opacity = (i / 36) * 0.35;
      canvas.drawLine(
        Offset(a.dx + w/2, a.dy + h/2),
        Offset(b.dx + w/2, b.dy + h/2),
        Paint()
          ..color = VK.sea.withValues(alpha: opacity)
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
    }

    // Plane transform
    final pos   = _b(p0, c1, c2, p3, progress);
    final nxt   = _b(p0, c1, c2, p3, math.min(1.0, progress + 0.02));
    final angle = math.atan2(nxt.dy - pos.dy, nxt.dx - pos.dx);
    final s     = unitSize;

    canvas.save();
    canvas.translate(pos.dx + w/2, pos.dy + h/2);
    canvas.rotate(angle);

    // Glow halo behind plane
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-s*0.1, 0), width: s*1.4, height: s*0.55),
      Paint()
        ..color = VK.sea.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    // Fuselage
    canvas
      ..drawPath(Path()
        ..moveTo( s*0.55,  0)
        ..lineTo(-s*0.28, -s*0.12)
        ..lineTo(-s*0.10,  0)
        ..lineTo(-s*0.28,  s*0.12)
        ..close(), paint)
      // Left wing
      ..drawPath(Path()
        ..moveTo( s*0.05,  0)
        ..lineTo(-s*0.08, -s*0.38)
        ..lineTo(-s*0.24, -s*0.38)
        ..lineTo(-s*0.22, -s*0.14)
        ..close(), paint)
      // Right wing
      ..drawPath(Path()
        ..moveTo( s*0.05,  0)
        ..lineTo(-s*0.08,  s*0.38)
        ..lineTo(-s*0.24,  s*0.38)
        ..lineTo(-s*0.22,  s*0.14)
        ..close(), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlanePainter o) => o.progress != progress;
}

/* ─── Main App ───────────────────────────────────────────────────────────── */

class WejhaApp extends StatelessWidget {
  const WejhaApp({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return MaterialApp(
      title: 'Wejha',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      themeMode: ThemeMode.dark,
      locale: Locale(s.lang),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Shell(),
    );
  }
}

/* ─── Shell ──────────────────────────────────────────────────────────────── */

class Shell extends StatelessWidget {
  const Shell({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    const pages = [
      HomeScreen(), DiscoverScreen(), TripScreen(), ConciergeScreen(), ProfileScreen(),
    ];
    final dests = [
      (Icons.home_outlined,       Icons.home,        s.t('home')),
      (Icons.explore_outlined,    Icons.explore,     s.t('discover')),
      (Icons.luggage_outlined,    Icons.luggage,     s.t('myTrip')),
      (Icons.chat_bubble_outline, Icons.chat_bubble, s.t('concierge')),
      (Icons.person_outline,      Icons.person,      s.t('profile')),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final body = SafeArea(child: IndexedStack(index: s.tab, children: pages));
    if (wide) {
      return Scaffold(
        body: Row(children: [
          NavigationRail(
            selectedIndex: s.tab,
            onDestinationSelected: s.setTab,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Image.asset('assets/images/logo_stacked.png', width: 80),
            ),
            destinations: [
              for (final d in dests)
                NavigationRailDestination(
                    icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: Text(d.$3)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ]),
      );
    }
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: s.tab,
        onDestinationSelected: s.setTab,
        destinations: [
          for (final d in dests)
            NavigationDestination(
                icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
        ],
      ),
    );
  }
}
