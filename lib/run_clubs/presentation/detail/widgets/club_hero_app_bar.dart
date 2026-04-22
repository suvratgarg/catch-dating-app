import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:flutter/material.dart';

class ClubHeroAppBar extends StatelessWidget {
  const ClubHeroAppBar({super.key, required this.club, required this.isHost});

  final RunClub club;
  final bool isHost;

  static const _expandedHeight = 260.0;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SliverAppBar(
      expandedHeight: _expandedHeight,
      pinned: true,
      backgroundColor: t.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: IconBtn(
          background: Colors.black.withValues(alpha: 0.35),
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
          child: IconBtn(
            background: Colors.black.withValues(alpha: 0.35),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sharing for run clubs is coming soon.'),
              ),
            ),
            child: const Icon(
              Icons.ios_share_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            club.imageUrl != null
                ? Image.network(
                    club.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ClubGradientBg(name: club.name),
                  )
                : ClubGradientBg(name: club.name),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: CatchSpacing.screenH,
              right: CatchSpacing.screenH,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isHost)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: t.primary,
                        borderRadius: BorderRadius.circular(CatchRadius.button),
                      ),
                      child: Text(
                        'HOST',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: t.primaryInk,
                        ),
                      ),
                    ),
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        club.location.label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      if (club.rating > 0) ...[
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          club.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClubGradientBg extends StatelessWidget {
  const ClubGradientBg({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    final gradients = [
      [const Color(0xFF1A2E2A), const Color(0xFF0F3020)],
      [const Color(0xFF1E2A3A), const Color(0xFF0A1828)],
      [const Color(0xFF2A1A1A), const Color(0xFF3D0F0F)],
      [const Color(0xFF1A1A2E), const Color(0xFF0F0F3D)],
    ];
    final pair = gradients[hash % gradients.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pair,
        ),
      ),
      child: Center(
        child: Text(
          name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join(),
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w700,
            color: t.primary.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
