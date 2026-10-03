import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // Show the splash immediately, then load data in the background.
  runApp(const _SplashApp());
  await initializeDateFormatting('en');
  await initializeDateFormatting('ar');
  final state = AppState();
  await state.load();
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
        body: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Wejh',
                      style: GoogleFonts.cairo(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: VK.sea,
                        height: 1,
                      ),
                    ),
                    Transform.rotate(
                      angle: -0.4,
                      child: const Icon(Icons.flight, size: 50, color: VK.sea),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'وجهة',
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: VK.ink2,
                    height: 1,
                  ),
                ),
              ],
            ),
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
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: WejhaLogo(size: 20),
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
