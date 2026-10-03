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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _SplashApp());
  final state = AppState();
  await Future.wait([
    initializeDateFormatting('en'),
    initializeDateFormatting('ar'),
    state.load(),
    Future.delayed(const Duration(milliseconds: 3200)),
  ]);
  runApp(AppScope(state: state, child: const WejhaApp()));
}

/* ─── Splash ─────────────────────────────────────────────────────────────── */

class _SplashApp extends StatefulWidget {
  const _SplashApp();
  @override
  State<_SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<_SplashApp> with SingleTickerProviderStateMixin {
  // One controller drives every phase via Interval curves.
  // Total: 3200 ms  (matches the Future.delayed above)
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Interval helpers ──────────────────────────────────────────────────────
  Animation<double> _interval(double t0, double t1, {Curve curve = Curves.linear}) =>
      CurvedAnimation(parent: _ctrl, curve: Interval(t0, t1, curve: curve));

  @override
  Widget build(BuildContext context) {
    final logoSize = MediaQuery.sizeOf(context).shortestSide * 0.46;

    // ── Phase timing (fractions of 3200 ms) ──────────────────────────────
    // 01  Spark appears            0.00 – 0.12  (~0–384 ms)
    // 02  Arc draws                0.08 – 0.44  (~256–1408 ms)
    // 03  Logo fades/scales in     0.38 – 0.62  (~1216–1984 ms)
    // 04  Arc fades out            0.40 – 0.58  (overlaps logo in)
    // 05  Plane flies              0.62 – 0.90  (~1984–2880 ms)
    // 06  Plane fades out          0.87 – 0.97
    // 07  Final glow settle        0.90 – 1.00

    final sparkOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 35),
      TweenSequenceItem(tween: ConstantTween(1.0),           weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 45),
    ]).animate(_interval(0.00, 0.14, curve: Curves.easeInOut));

    final arcProgress = _interval(0.08, 0.44, curve: Curves.easeInOut);

    final arcOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0),           weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_interval(0.08, 0.58, curve: Curves.easeInOut));

    final bgGlow   = _interval(0.28, 0.70, curve: Curves.easeOut);

    final logoFade = _interval(0.38, 0.62, curve: Curves.easeOut);
    final logoScale = Tween<double>(begin: 0.80, end: 1.0).animate(
      _interval(0.38, 0.64, curve: Curves.easeOutBack),
    );

    final planeProgress = _interval(0.62, 0.90, curve: Curves.easeInOut);
    final planeOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1.0),           weight: 68),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_interval(0.62, 0.97, curve: Curves.easeInOut));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        backgroundColor: VK.bg,
        body: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [

              // ── Radial background glow ──────────────────────────────────
              Center(
                child: Opacity(
                  opacity: (bgGlow.value * 0.40).clamp(0.0, 1.0),
                  child: Container(
                    width: logoSize * 2.4,
                    height: logoSize * 2.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          VK.sea.withValues(alpha: 0.45),
                          VK.sea.withValues(alpha: 0.08),
                          VK.bg,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Arc drawing ─────────────────────────────────────────────
              Center(
                child: Opacity(
                  opacity: arcOpacity.value.clamp(0.0, 1.0),
                  child: CustomPaint(
                    size: Size(logoSize, logoSize),
                    painter: _ArcPainter(progress: arcProgress.value),
                  ),
                ),
              ),

              // ── Leading spark ────────────────────────────────────────────
              // Positioned at the arc's leading edge during draw phase
              Center(
                child: Opacity(
                  opacity: sparkOpacity.value.clamp(0.0, 1.0),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: VK.sea.withValues(alpha: 0.9),
                          blurRadius: 28,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.7),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Logo PNG reveal ──────────────────────────────────────────
              Center(
                child: Opacity(
                  opacity: logoFade.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: logoScale.value,
                    child: Image.asset(
                      'assets/images/logo_icon.png',
                      width: logoSize,
                      height: logoSize,
                    ),
                  ),
                ),
              ),

              // ── Airplane ─────────────────────────────────────────────────
              Center(
                child: Opacity(
                  opacity: planeOpacity.value.clamp(0.0, 1.0),
                  child: CustomPaint(
                    size: Size(logoSize, logoSize),
                    painter: _PlanePainter(
                      progress: planeProgress.value,
                      logoSize: logoSize,
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

/* ─── Arc painter ────────────────────────────────────────────────────────── */
/// Draws a glowing arc that traces the circular ring of the Wejha location pin,
/// with a bright spark dot at the leading edge.
class _ArcPainter extends CustomPainter {
  final double progress;
  const _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    // Circle sits in the upper 58% of the logo, centred horizontally.
    final centre = Offset(size.width * 0.50, size.height * 0.355);
    final radius = size.width * 0.295;

    // Start at ~10 o'clock, sweep clockwise ~300°
    const startAngle = -math.pi * 0.72;
    const totalSweep = math.pi * 1.67;
    final sweep = totalSweep * progress;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    // Outer soft glow
    canvas.drawArc(rect, startAngle, sweep, false,
      Paint()
        ..color = VK.sea.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));

    // Mid glow
    canvas.drawArc(rect, startAngle, sweep, false,
      Paint()
        ..color = VK.sea.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // Core bright line
    canvas.drawArc(rect, startAngle, sweep, false,
      Paint()
        ..color = VK.sea
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round);

    // Leading spark dot
    if (progress > 0.03) {
      final leadAngle = startAngle + sweep;
      final dx = centre.dx + radius * math.cos(leadAngle);
      final dy = centre.dy + radius * math.sin(leadAngle);

      canvas.drawCircle(Offset(dx, dy), 11,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
      canvas.drawCircle(Offset(dx, dy), 5,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawCircle(Offset(dx, dy), 2.2,
        Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

/* ─── Plane painter ──────────────────────────────────────────────────────── */
/// Draws a small airplane flying a cubic-bezier arc from lower-left to
/// upper-right across the logo, matching the storyboard's swoosh trajectory.
class _PlanePainter extends CustomPainter {
  final double progress;
  final double logoSize;
  const _PlanePainter({required this.progress, required this.logoSize});

  // Cubic bezier
  Offset _bez(Offset p0, Offset c1, Offset c2, Offset p3, double t) {
    final mt = 1 - t;
    return Offset(
      mt * mt * mt * p0.dx + 3 * mt * mt * t * c1.dx + 3 * mt * t * t * c2.dx + t * t * t * p3.dx,
      mt * mt * mt * p0.dy + 3 * mt * mt * t * c1.dy + 3 * mt * t * t * c2.dy + t * t * t * p3.dy,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final w = size.width;
    final h = size.height;

    // Path: bottom-left → sweeps up-right (mirrors the logo's swoosh arc)
    final p0 = Offset(-w * 0.60, h * 0.70);
    final c1 = Offset(-w * 0.15, h * 0.42);
    final c2 = Offset( w * 0.30, h * 0.05);
    final p3 = Offset( w * 0.82, -h * 0.30);

    // ── Trail ────────────────────────────────────────────────────────────
    final trailStart = math.max(0.0, progress - 0.40);
    final trailPath = Path();
    var first = true;
    for (var i = 0; i <= 40; i++) {
      final t = trailStart + (progress - trailStart) * i / 40;
      final pt = _bez(p0, c1, c2, p3, t);
      final gx = pt.dx + w / 2, gy = pt.dy + h / 2;
      if (first) {
        trailPath.moveTo(gx, gy);
        first = false;
      } else {
        trailPath.lineTo(gx, gy);
      }
    }
    canvas.drawPath(trailPath,
      Paint()
        ..color = VK.sea.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round);

    // ── Plane body ────────────────────────────────────────────────────────
    final pos   = _bez(p0, c1, c2, p3, progress);
    final ahead = _bez(p0, c1, c2, p3, math.min(1.0, progress + 0.025));
    final angle = math.atan2(ahead.dy - pos.dy, ahead.dx - pos.dx);

    canvas.save();
    canvas.translate(pos.dx + w / 2, pos.dy + h / 2);
    canvas.rotate(angle);

    final s = logoSize * 0.13; // plane scale

    // Glow halo
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: s * 1.2, height: s * 0.5),
      Paint()
        ..color = VK.sea.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // Fuselage
    final body = Path()
      ..moveTo( s * 0.52,  0)
      ..lineTo(-s * 0.30, -s * 0.13)
      ..lineTo(-s * 0.12,  0)
      ..lineTo(-s * 0.30,  s * 0.13)
      ..close();

    // Left wing
    final lwing = Path()
      ..moveTo( s * 0.06,  0)
      ..lineTo(-s * 0.08, -s * 0.36)
      ..lineTo(-s * 0.24, -s * 0.36)
      ..lineTo(-s * 0.22, -s * 0.16)
      ..close();

    // Right wing
    final rwing = Path()
      ..moveTo( s * 0.06,  0)
      ..lineTo(-s * 0.08,  s * 0.36)
      ..lineTo(-s * 0.24,  s * 0.36)
      ..lineTo(-s * 0.22,  s * 0.16)
      ..close();

    final planePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    canvas.drawPath(body,  planePaint);
    canvas.drawPath(lwing, planePaint);
    canvas.drawPath(rwing, planePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlanePainter old) => old.progress != progress;
}

/* ─── Main app ───────────────────────────────────────────────────────────── */

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
    const pages = [HomeScreen(), DiscoverScreen(), TripScreen(), ConciergeScreen(), ProfileScreen()];
    final dests = [
      (Icons.home_outlined, Icons.home, s.t('home')),
      (Icons.explore_outlined, Icons.explore, s.t('discover')),
      (Icons.luggage_outlined, Icons.luggage, s.t('myTrip')),
      (Icons.chat_bubble_outline, Icons.chat_bubble, s.t('concierge')),
      (Icons.person_outline, Icons.person, s.t('profile')),
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
                NavigationRailDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: Text(d.$3)),
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
          for (final d in dests) NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
        ],
      ),
    );
  }
}
