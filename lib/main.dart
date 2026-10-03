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

// 14 frames × ~200 ms each = 2800 ms animation, then hold frame 14 briefly.
const _kSplashMs = 3000;

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
  static const _frames = 14; // frame 15 (app-icon square) excluded
  // Frames play over first 90% of duration, then hold on frame 14 briefly.
  static const _playWindow = 0.90;

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        backgroundColor: VK.bg,
        body: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            // Map controller value → frame index 0–14
            final t = (_ctrl.value / _playWindow).clamp(0.0, 1.0);
            final idx = (t * (_frames - 1)).floor().clamp(0, _frames - 1);
            final num = (idx + 1).toString().padLeft(2, '0');

            final size = MediaQuery.sizeOf(context).shortestSide * 0.52;
            return Center(
              child: SizedBox(
                width: size,
                height: size,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 90),
                  child: Image.asset(
                    'assets/images/splash_$num.png',
                    key: ValueKey(num),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
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
    const pages = [
      HomeScreen(),
      DiscoverScreen(),
      TripScreen(),
      ConciergeScreen(),
      ProfileScreen(),
    ];
    final dests = [
      (Icons.home_outlined,        Icons.home,         s.t('home')),
      (Icons.explore_outlined,     Icons.explore,      s.t('discover')),
      (Icons.luggage_outlined,     Icons.luggage,      s.t('myTrip')),
      (Icons.chat_bubble_outline,  Icons.chat_bubble,  s.t('concierge')),
      (Icons.person_outline,       Icons.person,       s.t('profile')),
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
