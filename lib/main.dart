import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/concierge_screen.dart';
import 'widgets/common.dart';
import 'screens/discover_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/trip_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _SplashApp());
  // Run init + minimum splash time in parallel so we never show less than 2s.
  final state = AppState();
  await Future.wait([
    initializeDateFormatting('en'),
    initializeDateFormatting('ar'),
    state.load(),
    Future.delayed(const Duration(milliseconds: 2000)),
  ]);
  runApp(AppScope(state: state, child: const WejhaApp()));
}

/* ─── Splash ─────────────────────────────────────────────────────────────── */

/// Shown while [AppState] loads. Fades in the Wejha wordmark on a dark canvas.
class _SplashApp extends StatefulWidget {
  const _SplashApp();
  @override
  State<_SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<_SplashApp> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
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
        body: FadeTransition(
          opacity: _fade,
          child: Image.asset(
            'assets/images/splash.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
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
