import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: DesignPersonalityPreviewApp()));
}

class DesignPersonalityPreviewApp extends StatelessWidget {
  const DesignPersonalityPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = Uri.base.queryParameters['theme'];
    final directions = switch (selected) {
      'light' => [PreviewTheme.lockedLight],
      'dark' => [PreviewTheme.lockedDarkEvent],
      'activity' => [PreviewTheme.activityEditorial],
      _ => PreviewTheme.all,
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catch Personality Preview',
      home: PreviewStage(directions: directions),
    );
  }
}

class PreviewStage extends StatelessWidget {
  const PreviewStage({required this.directions, super.key});

  final List<PreviewTheme> directions;

  @override
  Widget build(BuildContext context) {
    final single = directions.length == 1;
    return Scaffold(
      backgroundColor: single
          ? directions.single.stage
          : const Color(0xFFE8E2D7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(single ? 20 : 28),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final direction in directions) ...[
                  PhonePreview(theme: direction),
                  if (direction != directions.last) const SizedBox(width: 28),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PhonePreview extends StatelessWidget {
  const PhonePreview({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 844,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.bezel,
        borderRadius: BorderRadius.circular(46),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.isDark ? 0.55 : 0.22),
            blurRadius: 34,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Theme(
          data: ThemeData(
            useMaterial3: true,
            brightness: theme.isDark ? Brightness.dark : Brightness.light,
            fontFamily: theme.textFont,
            textTheme:
                ThemeData(
                  brightness: theme.isDark ? Brightness.dark : Brightness.light,
                ).textTheme.apply(
                  fontFamily: theme.textFont,
                  bodyColor: theme.ink,
                  displayColor: theme.ink,
                ),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: CatchMomentScreen(theme: theme),
          ),
        ),
      ),
    );
  }
}

class CatchMomentScreen extends StatelessWidget {
  const CatchMomentScreen({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: theme.bg,
      child: Stack(
        children: [
          Positioned.fill(child: AmbientBackground(theme: theme)),
          Positioned.fill(
            child: Column(
              children: [
                PreviewStatusBar(theme: theme),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 106),
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PreviewTopBar(theme: theme),
                        const SizedBox(height: 16),
                        HeroRunCard(theme: theme),
                        const SizedBox(height: 14),
                        SocialUnlockCard(theme: theme),
                        const SizedBox(height: 14),
                        SectionTitle(
                          theme: theme,
                          eyebrow: 'POST-RUN CATCHES',
                          title: 'People you actually ran with',
                        ),
                        const SizedBox(height: 10),
                        SwipePreviewCard(theme: theme),
                        const SizedBox(height: 14),
                        ChatCue(theme: theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: PreviewTabBar(theme: theme),
          ),
        ],
      ),
    );
  }
}

class PreviewStatusBar extends StatelessWidget {
  const PreviewStatusBar({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 9, 26, 0),
        child: Row(
          children: [
            Text(
              '6:42',
              style: TextStyle(
                color: theme.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Icon(Icons.signal_cellular_alt_rounded, size: 15, color: theme.ink),
            const SizedBox(width: 5),
            Icon(Icons.wifi_rounded, size: 15, color: theme.ink),
            const SizedBox(width: 5),
            Icon(Icons.battery_full_rounded, size: 16, color: theme.ink),
          ],
        ),
      ),
    );
  }
}

class PreviewTopBar extends StatelessWidget {
  const PreviewTopBar({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                theme.name,
                style: TextStyle(
                  color: theme.inkMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                theme.headline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.ink,
                  fontFamily: theme.displayFont,
                  fontSize: 27,
                  height: 1.02,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.line),
          ),
          child: Icon(Icons.notifications_none_rounded, color: theme.ink),
        ),
      ],
    );
  }
}

class HeroRunCard extends StatelessWidget {
  const HeroRunCard({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 218,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.heroBase,
        borderRadius: BorderRadius.circular(theme.radiusHero),
        boxShadow: theme.glowShadow,
      ),
      child: Stack(
        children: [
          Positioned.fill(child: RoutePhotoPainter(theme: theme)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: theme.isDark ? 0.05 : 0.00),
                    Colors.black.withValues(alpha: theme.isDark ? 0.20 : 0.06),
                    Colors.black.withValues(alpha: theme.isDark ? 0.58 : 0.24),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: PreviewPill(
              theme: theme,
              label: theme.heroPill,
              icon: Icons.directions_run_rounded,
              filled: true,
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.floating.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.map_rounded, color: theme.floatingInk),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sunrise 7K',
                  style: TextStyle(
                    color: theme.heroInk,
                    fontFamily: theme.displayFont,
                    fontSize: 35,
                    height: 0.94,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bandra Striders · Carter Road · 6:30 AM',
                  style: TextStyle(
                    color: theme.heroInk.withValues(alpha: 0.84),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: PreviewButton(
                        theme: theme,
                        label: 'Book spot',
                        icon: Icons.bolt_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    PreviewMetric(theme: theme, value: '11', label: 'left'),
                    const SizedBox(width: 8),
                    PreviewMetric(theme: theme, value: '5K', label: 'easy'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SocialUnlockCard extends StatelessWidget {
  const SocialUnlockCard({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return PreviewSurface(
      theme: theme,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          AvatarStack(theme: theme),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catches unlock after check-in',
                  style: TextStyle(
                    color: theme.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '4 runners are already in. Swipe window opens for 24h.',
                  style: TextStyle(
                    color: theme.inkMuted,
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CountdownBadge(theme: theme),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.theme,
    required this.eyebrow,
    required this.title,
    super.key,
  });

  final PreviewTheme theme;
  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            color: theme.primary,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: theme.ink,
            fontFamily: theme.displayFont,
            fontSize: 21,
            height: 1.05,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class SwipePreviewCard extends StatelessWidget {
  const SwipePreviewCard({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 206,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(theme.radiusCard),
        border: Border.all(color: theme.line),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 9,
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(theme.radiusCard),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PortraitBlock(theme: theme),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: PreviewPill(
                      theme: theme,
                      label: 'RAN WITH YOU',
                      icon: Icons.verified_rounded,
                      filled: true,
                      compact: true,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Text(
                      'Mira, 27',
                      style: TextStyle(
                        color: theme.photoInk,
                        fontFamily: theme.displayFont,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Steady miles, strong coffee, no small talk until km 3.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.ink,
                      fontSize: 15,
                      height: 1.18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      MiniChip(theme: theme, label: '5:40/km'),
                      MiniChip(theme: theme, label: '10K'),
                      MiniChip(theme: theme, label: 'Bandra'),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      RoundAction(
                        theme: theme,
                        icon: Icons.close_rounded,
                        color: theme.pass,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: RoundAction(
                          theme: theme,
                          icon: Icons.favorite_rounded,
                          color: theme.like,
                          expanded: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatCue extends StatelessWidget {
  const ChatCue({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return PreviewSurface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [theme.primary, theme.accent]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.chat_bubble_rounded, color: theme.onPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "It's a catch with Riya",
                  style: TextStyle(
                    color: theme.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'You both ran Sunrise 7K. Start with that.',
                  style: TextStyle(
                    color: theme.inkMuted,
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: theme.primary),
        ],
      ),
    );
  }
}

class PreviewTabBar extends StatelessWidget {
  const PreviewTabBar({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Home', false),
      (Icons.groups_rounded, 'Clubs', false),
      (Icons.favorite_rounded, 'Catches', true),
      (Icons.chat_rounded, 'Chats', false),
      (Icons.person_rounded, 'You', false),
    ];

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.nav,
        borderRadius: BorderRadius.circular(theme.navRadius),
        border: Border.all(color: theme.line),
        boxShadow: theme.navShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final item in items)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.$1,
                    size: 21,
                    color: item.$3 ? theme.primary : theme.inkMuted,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: item.$3 ? theme.primary : theme.inkMuted,
                      fontSize: 10,
                      fontWeight: item.$3 ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PreviewSurface extends StatelessWidget {
  const PreviewSurface({
    required this.theme,
    required this.child,
    required this.padding,
    super.key,
  });

  final PreviewTheme theme;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(theme.radiusCard),
        border: Border.all(color: theme.line),
        boxShadow: theme.cardShadow,
      ),
      child: child,
    );
  }
}

class PreviewButton extends StatelessWidget {
  const PreviewButton({
    required this.theme,
    required this.label,
    required this.icon,
    super.key,
  });

  final PreviewTheme theme;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.cta,
        borderRadius: BorderRadius.circular(theme.buttonRadius),
        boxShadow: theme.ctaShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: theme.ctaInk),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: theme.ctaInk,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewMetric extends StatelessWidget {
  const PreviewMetric({
    required this.theme,
    required this.value,
    required this.label,
    super.key,
  });

  final PreviewTheme theme;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 48,
      decoration: BoxDecoration(
        color: theme.metricBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.metricBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: theme.metricInk,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: theme.metricInk.withValues(alpha: 0.72),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewPill extends StatelessWidget {
  const PreviewPill({
    required this.theme,
    required this.label,
    required this.icon,
    this.filled = false,
    this.compact = false,
    super.key,
  });

  final PreviewTheme theme;
  final String label;
  final IconData icon;
  final bool filled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? theme.pillBg : theme.surface;
    final fg = filled ? theme.pillInk : theme.primary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: filled ? Colors.transparent : theme.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniChip extends StatelessWidget {
  const MiniChip({required this.theme, required this.label, super.key});

  final PreviewTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.chip,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.chipLine),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.chipInk,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class RoundAction extends StatelessWidget {
  const RoundAction({
    required this.theme,
    required this.icon,
    required this.color,
    this.expanded = false,
    super.key,
  });

  final PreviewTheme theme;
  final IconData icon;
  final Color color;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expanded ? null : 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: theme.onPrimary),
    );
  }
}

class AvatarStack extends StatelessWidget {
  const AvatarStack({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    final colors = [theme.primary, theme.accent, theme.secondary];
    return SizedBox(
      width: 72,
      height: 38,
      child: Stack(
        children: [
          for (var i = 0; i < 3; i++)
            Positioned(
              left: i * 19,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.surface, width: 3),
                ),
                child: Center(
                  child: Text(
                    ['M', 'R', '+'][i],
                    style: TextStyle(
                      color: i == 2 ? theme.secondaryInk : theme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CountdownBadge extends StatelessWidget {
  const CountdownBadge({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.primary, theme.accent]),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '2h',
            style: TextStyle(
              color: theme.onPrimary,
              fontSize: 18,
              height: 0.95,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'left',
            style: TextStyle(
              color: theme.onPrimary.withValues(alpha: 0.78),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: AmbientPainter(theme));
  }
}

class RoutePhotoPainter extends StatelessWidget {
  const RoutePhotoPainter({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: RoutePainter(theme));
  }
}

class PortraitBlock extends StatelessWidget {
  const PortraitBlock({required this.theme, super.key});

  final PreviewTheme theme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: PortraitPainter(theme));
  }
}

class AmbientPainter extends CustomPainter {
  AmbientPainter(this.theme);

  final PreviewTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = theme.primary.withValues(alpha: theme.isDark ? 0.14 : 0.10);
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.22),
      108,
      paint,
    );
    paint.color = theme.accent.withValues(alpha: theme.isDark ? 0.15 : 0.08);
    canvas.drawCircle(
      Offset(size.width * 1.03, size.height * 0.10),
      122,
      paint,
    );

    final linePaint = Paint()
      ..color = theme.line.withValues(alpha: theme.isDark ? 0.58 : 0.42)
      ..strokeWidth = 1;
    for (var y = 110.0; y < size.height; y += 78) {
      canvas.drawLine(
        Offset(-20, y),
        Offset(size.width + 20, y - 38),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AmbientPainter oldDelegate) => false;
}

class RoutePainter extends CustomPainter {
  RoutePainter(this.theme);

  final PreviewTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: theme.heroGradient,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final block = Paint()..color = theme.photoWash.withValues(alpha: 0.30);
    for (var i = 0; i < 7; i++) {
      final top = 22.0 + i * 28;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i.isEven ? -20 : size.width * 0.36,
            top,
            size.width * 0.74,
            14,
          ),
          const Radius.circular(999),
        ),
        block,
      );
    }

    final route = Path()
      ..moveTo(size.width * 0.10, size.height * 0.44)
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.20,
        size.width * 0.48,
        size.height * 0.78,
        size.width * 0.62,
        size.height * 0.38,
      )
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.04,
        size.width * 0.88,
        size.height * 0.56,
        size.width * 0.76,
        size.height * 0.72,
      );
    final routeShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(route, routeShadow);
    final routePaint = Paint()
      ..color = theme.routeLine
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(route, routePaint);

    final marker = Paint()..color = theme.secondary;
    canvas.drawCircle(
      Offset(size.width * 0.62, size.height * 0.38),
      13,
      marker,
    );
    canvas.drawCircle(
      Offset(size.width * 0.62, size.height * 0.38),
      6,
      Paint()..color = theme.secondaryInk,
    );
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) => false;
}

class PortraitPainter extends CustomPainter {
  PortraitPainter(this.theme);

  final PreviewTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.portraitTop, theme.portraitBottom],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final sun = Paint()..color = theme.secondary.withValues(alpha: 0.82);
    canvas.drawCircle(Offset(size.width * 0.70, size.height * 0.25), 36, sun);

    final person = Paint()..color = theme.photoSubject;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.46, size.height * 0.42),
        width: 52,
        height: 62,
      ),
      person,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.23, size.height * 0.56, 86, 88),
        const Radius.circular(46),
      ),
      person,
    );

    final track = Paint()
      ..color = theme.photoWash.withValues(alpha: 0.52)
      ..strokeWidth = 4;
    for (var i = 0; i < 5; i++) {
      final y = size.height * 0.74 + i * 12;
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 18), track);
    }
  }

  @override
  bool shouldRepaint(covariant PortraitPainter oldDelegate) => false;
}

@immutable
class PreviewTheme {
  const PreviewTheme({
    required this.name,
    required this.headline,
    required this.stage,
    required this.bezel,
    required this.bg,
    required this.surface,
    required this.nav,
    required this.floating,
    required this.floatingInk,
    required this.ink,
    required this.inkMuted,
    required this.line,
    required this.primary,
    required this.accent,
    required this.secondary,
    required this.secondaryInk,
    required this.onPrimary,
    required this.cta,
    required this.ctaInk,
    required this.chip,
    required this.chipInk,
    required this.chipLine,
    required this.heroGradient,
    required this.heroBase,
    required this.heroInk,
    required this.heroPill,
    required this.pillBg,
    required this.pillInk,
    required this.routeLine,
    required this.photoWash,
    required this.portraitTop,
    required this.portraitBottom,
    required this.photoSubject,
    required this.photoInk,
    required this.like,
    required this.pass,
    required this.displayFont,
    required this.textFont,
    required this.radiusHero,
    required this.radiusCard,
    required this.buttonRadius,
    required this.navRadius,
    required this.isDark,
    required this.cardShadow,
    required this.glowShadow,
    required this.navShadow,
    required this.ctaShadow,
    required this.metricBg,
    required this.metricBorder,
    required this.metricInk,
  });

  final String name;
  final String headline;
  final Color stage;
  final Color bezel;
  final Color bg;
  final Color surface;
  final Color nav;
  final Color floating;
  final Color floatingInk;
  final Color ink;
  final Color inkMuted;
  final Color line;
  final Color primary;
  final Color accent;
  final Color secondary;
  final Color secondaryInk;
  final Color onPrimary;
  final Color cta;
  final Color ctaInk;
  final Color chip;
  final Color chipInk;
  final Color chipLine;
  final List<Color> heroGradient;
  final Color heroBase;
  final Color heroInk;
  final String heroPill;
  final Color pillBg;
  final Color pillInk;
  final Color routeLine;
  final Color photoWash;
  final Color portraitTop;
  final Color portraitBottom;
  final Color photoSubject;
  final Color photoInk;
  final Color like;
  final Color pass;
  final String displayFont;
  final String textFont;
  final double radiusHero;
  final double radiusCard;
  final double buttonRadius;
  final double navRadius;
  final bool isDark;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> glowShadow;
  final List<BoxShadow> navShadow;
  final List<BoxShadow> ctaShadow;
  final Color metricBg;
  final Color metricBorder;
  final Color metricInk;

  static final all = [lockedLight, lockedDarkEvent, activityEditorial];

  static final lockedLight = PreviewTheme(
    name: 'LOCKED LIGHT',
    headline: 'Show up. Then swipe.',
    stage: const Color(0xFFFFF2E7),
    bezel: const Color(0xFF15100D),
    bg: const Color(0xFFFFF5EC),
    surface: const Color(0xFFFFFFFF),
    nav: const Color(0xF7FFFFFF),
    floating: const Color(0xFFFFFFFF),
    floatingInk: const Color(0xFF15100D),
    ink: const Color(0xFF17110E),
    inkMuted: const Color(0xFF6B5C50),
    line: const Color(0x1F17110E),
    primary: const Color(0xFFFF4A1F),
    accent: const Color(0xFF2447FF),
    secondary: const Color(0xFFC7FF44),
    secondaryInk: const Color(0xFF12130B),
    onPrimary: const Color(0xFFFFFFFF),
    cta: const Color(0xFF17110E),
    ctaInk: const Color(0xFFFFFFFF),
    chip: const Color(0xFFFFE7DA),
    chipInk: const Color(0xFFDA3E19),
    chipLine: const Color(0x24FF4A1F),
    heroGradient: const [
      Color(0xFFFF4A1F),
      Color(0xFFFF8B38),
      Color(0xFF2447FF),
    ],
    heroBase: const Color(0xFFFF6B2B),
    heroInk: const Color(0xFFFFFFFF),
    heroPill: 'TONIGHT · 6:30',
    pillBg: const Color(0xFFFFFFFF),
    pillInk: const Color(0xFFFF4A1F),
    routeLine: const Color(0xFFFFFFFF),
    photoWash: const Color(0xFFFFFFFF),
    portraitTop: const Color(0xFFFFB68B),
    portraitBottom: const Color(0xFF2447FF),
    photoSubject: const Color(0xFF1B110E),
    photoInk: const Color(0xFFFFFFFF),
    like: const Color(0xFFFF4A1F),
    pass: const Color(0xFF17110E),
    displayFont: 'Archivo',
    textFont: 'system-ui',
    radiusHero: 32,
    radiusCard: 24,
    buttonRadius: 18,
    navRadius: 28,
    isDark: false,
    cardShadow: [
      BoxShadow(
        color: const Color(0xFFFF4A1F).withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
    glowShadow: [
      BoxShadow(
        color: const Color(0xFFFF4A1F).withValues(alpha: 0.28),
        blurRadius: 28,
        offset: const Offset(0, 14),
      ),
    ],
    navShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ],
    ctaShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
    metricBg: const Color(0xF7FFFFFF),
    metricBorder: const Color(0x55FFFFFF),
    metricInk: const Color(0xFF17110E),
  );

  static final lockedDarkEvent = PreviewTheme(
    name: 'LOCKED DARK EVENT',
    headline: 'The after-event window.',
    stage: const Color(0xFF060A12),
    bezel: const Color(0xFF000000),
    bg: const Color(0xFF070A12),
    surface: const Color(0xFF111722),
    nav: const Color(0xEE111722),
    floating: const Color(0xFFDBFF3D),
    floatingInk: const Color(0xFF070A12),
    ink: const Color(0xFFF8FBFF),
    inkMuted: const Color(0xFF9AA9B9),
    line: const Color(0x22FFFFFF),
    primary: const Color(0xFF00E7FF),
    accent: const Color(0xFFFF2D72),
    secondary: const Color(0xFFDBFF3D),
    secondaryInk: const Color(0xFF070A12),
    onPrimary: const Color(0xFF070A12),
    cta: const Color(0xFFDBFF3D),
    ctaInk: const Color(0xFF070A12),
    chip: const Color(0x1F00E7FF),
    chipInk: const Color(0xFF85F5FF),
    chipLine: const Color(0x5500E7FF),
    heroGradient: const [
      Color(0xFF07111F),
      Color(0xFF102B52),
      Color(0xFFFF2D72),
    ],
    heroBase: const Color(0xFF101829),
    heroInk: const Color(0xFFFFFFFF),
    heroPill: 'LIVE SOON',
    pillBg: const Color(0xFF00E7FF),
    pillInk: const Color(0xFF070A12),
    routeLine: const Color(0xFFDBFF3D),
    photoWash: const Color(0xFF00E7FF),
    portraitTop: const Color(0xFF172B52),
    portraitBottom: const Color(0xFF070A12),
    photoSubject: const Color(0xFFFF2D72),
    photoInk: const Color(0xFFFFFFFF),
    like: const Color(0xFFFF2D72),
    pass: const Color(0xFF00E7FF),
    displayFont: 'Archivo',
    textFont: 'system-ui',
    radiusHero: 22,
    radiusCard: 20,
    buttonRadius: 999,
    navRadius: 999,
    isDark: true,
    cardShadow: [
      BoxShadow(
        color: const Color(0xFF00E7FF).withValues(alpha: 0.10),
        blurRadius: 26,
        offset: const Offset(0, 10),
      ),
    ],
    glowShadow: [
      BoxShadow(
        color: const Color(0xFFFF2D72).withValues(alpha: 0.30),
        blurRadius: 36,
        offset: const Offset(0, 16),
      ),
      BoxShadow(
        color: const Color(0xFF00E7FF).withValues(alpha: 0.18),
        blurRadius: 28,
        offset: const Offset(0, 2),
      ),
    ],
    navShadow: [
      BoxShadow(
        color: const Color(0xFF00E7FF).withValues(alpha: 0.12),
        blurRadius: 26,
        offset: const Offset(0, 10),
      ),
    ],
    ctaShadow: [
      BoxShadow(
        color: const Color(0xFFDBFF3D).withValues(alpha: 0.28),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
    metricBg: const Color(0x25111122),
    metricBorder: const Color(0x6600E7FF),
    metricInk: const Color(0xFFFFFFFF),
  );

  static final activityEditorial = PreviewTheme(
    name: 'ACTIVITY EDITORIAL',
    headline: 'A better way to meet.',
    stage: const Color(0xFFEDE6DA),
    bezel: const Color(0xFF17130E),
    bg: const Color(0xFFF2EDE3),
    surface: const Color(0xFFFFFCF5),
    nav: const Color(0xFAFFFCF5),
    floating: const Color(0xFF1C1A14),
    floatingInk: const Color(0xFFFFFCF5),
    ink: const Color(0xFF1C1A14),
    inkMuted: const Color(0xFF6D604F),
    line: const Color(0x241C1A14),
    primary: const Color(0xFFC7502C),
    accent: const Color(0xFF43532B),
    secondary: const Color(0xFFD8A14A),
    secondaryInk: const Color(0xFF1C1A14),
    onPrimary: const Color(0xFFFFFCF5),
    cta: const Color(0xFFC7502C),
    ctaInk: const Color(0xFFFFFCF5),
    chip: const Color(0xFFF4DDD1),
    chipInk: const Color(0xFF9D3B22),
    chipLine: const Color(0x2EC7502C),
    heroGradient: const [
      Color(0xFFC7502C),
      Color(0xFFE1A66D),
      Color(0xFF43532B),
    ],
    heroBase: const Color(0xFFC7502C),
    heroInk: const Color(0xFFFFFCF5),
    heroPill: 'SUNDAY CLUB',
    pillBg: const Color(0xFFFFFCF5),
    pillInk: const Color(0xFFC7502C),
    routeLine: const Color(0xFFFFFCF5),
    photoWash: const Color(0xFFFFFCF5),
    portraitTop: const Color(0xFFE8B27C),
    portraitBottom: const Color(0xFF43532B),
    photoSubject: const Color(0xFF1C1A14),
    photoInk: const Color(0xFFFFFCF5),
    like: const Color(0xFFC7502C),
    pass: const Color(0xFF1C1A14),
    displayFont: 'Archivo',
    textFont: 'system-ui',
    radiusHero: 18,
    radiusCard: 16,
    buttonRadius: 12,
    navRadius: 18,
    isDark: false,
    cardShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.07),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ],
    glowShadow: [
      BoxShadow(
        color: const Color(0xFFC7502C).withValues(alpha: 0.16),
        blurRadius: 24,
        offset: const Offset(0, 14),
      ),
    ],
    navShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.10),
        blurRadius: 22,
        offset: const Offset(0, 12),
      ),
    ],
    ctaShadow: [
      BoxShadow(
        color: const Color(0xFFC7502C).withValues(alpha: 0.20),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
    metricBg: const Color(0xEEFFFCF5),
    metricBorder: const Color(0x55FFFCF5),
    metricInk: const Color(0xFF1C1A14),
  );
}
