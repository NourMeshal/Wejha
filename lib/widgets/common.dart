import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/trip.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Event/place artwork. Shows a network photo when [imageUrl] is provided,
/// falling back to a motif gradient+icon if the URL is null or fails to load.
class ArtTile extends StatelessWidget {
  final String motif;
  final String? imageUrl;
  final double? width, height;
  final BorderRadius radius;
  const ArtTile(this.motif, {super.key, this.imageUrl, this.width, this.height, this.radius = BorderRadius.zero});

  static const _colors = <String, List<Color>>{
    'towers': [Color(0xFF1D6470), Color(0xFF8CCBBE)],
    'waves': [Color(0xFF1E5C7A), Color(0xFF9FD3E0)],
    'dunes': [Color(0xFFB5732E), Color(0xFFF1CF8E)],
    'arch': [Color(0xFF7A4E2D), Color(0xFFE7C79C)],
    'stage': [Color(0xFF3A2350), Color(0xFFE6B547)],
    'plate': [Color(0xFF6B3A22), Color(0xFFF0B77A)],
    'cup': [Color(0xFF4A2F22), Color(0xFFD9A27A)],
    'bag': [Color(0xFF24404A), Color(0xFFE5A6A0)],
    'film': [Color(0xFF1F2430), Color(0xFF8EA4C8)],
    'ball': [Color(0xFF1F5A3A), Color(0xFFA6D9A0)],
    'star': [Color(0xFF22305E), Color(0xFFF2C14E)],
    'leaf': [Color(0xFF2E5B3C), Color(0xFFB9DDA5)],
    'frame': [Color(0xFF3C3F52), Color(0xFFD8CDB8)],
    'sadu': [Color(0xFF7D1F1F), Color(0xFFF3E6D0)],
    'dome': [Color(0xFF20476B), Color(0xFFCFE0EE)],
    'speed': [Color(0xFF2B2B33), Color(0xFFE2563C)],
  };
  static const _icons = <String, IconData>{
    'towers': Icons.location_city, 'waves': Icons.water, 'dunes': Icons.landscape, 'arch': Icons.storefront,
    'stage': Icons.theater_comedy, 'plate': Icons.restaurant, 'cup': Icons.local_cafe, 'bag': Icons.shopping_bag,
    'film': Icons.movie, 'ball': Icons.sports_soccer, 'star': Icons.celebration, 'leaf': Icons.park,
    'frame': Icons.museum, 'sadu': Icons.texture, 'dome': Icons.mosque, 'speed': Icons.sports_motorsports,
  };

  Widget _gradient() {
    final c = _colors[motif] ?? _colors['towers']!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c[0], Color.lerp(c[0], c[1], .35)!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(child: Icon(_icons[motif] ?? Icons.place, color: c[1], size: 36)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = imageUrl != null
        ? Image.network(
            imageUrl!,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _gradient(),
            loadingBuilder: (_, loaded, progress) => progress == null ? loaded : _gradient(),
          )
        : _gradient();
    return ClipRRect(borderRadius: radius, child: child);
  }
}


/// App wordmark. "Wejh" in bold + a tilted plane that reads as the letter 'a'.
class WejhaLogo extends StatelessWidget {
  final double size;
  const WejhaLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Wejh',
          style: GoogleFonts.cairo(
            fontSize: size,
            fontWeight: FontWeight.w800,
            color: primary,
            height: 1,
          ),
        ),
        Transform.rotate(
          angle: -0.4,
          child: Icon(Icons.flight, size: size * 0.95, color: VK.sea),
        ),
      ],
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color bg, fg;
  const Pill(this.text, {super.key, this.bg = VK.surface2, this.fg = VK.ink2});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Text(text, style: TextStyle(fontSize: 13, color: fg, fontWeight: FontWeight.w600)),
      );
}

Widget statusPill(AppState s, BookingStatus st) {
  switch (st) {
    case BookingStatus.confirmed:
      return Pill(s.t('confirmed'), bg: VK.ok.withValues(alpha: .14), fg: VK.ok);
    case BookingStatus.cancelled:
      return Pill(s.t('cancelled'), bg: VK.danger.withValues(alpha: .14), fg: VK.danger);
    case BookingStatus.reserved:
      return Pill(s.t('reserved'), bg: VK.saffronBg, fg: VK.saffron);
    case BookingStatus.paymentRequired:
      return Pill(s.t('paymentRequired'), bg: VK.saffronBg, fg: VK.saffron);
    default:
      return const SizedBox.shrink();
  }
}

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
}

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children, bool banner = false});
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: [...children],
      );
}
