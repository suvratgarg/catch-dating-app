part of 'event_success_feature_blocks.dart';

class BlockHeader extends StatelessWidget {
  const BlockHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: t.primary),
            const SizedBox(width: CatchSpacing.s2),
            Expanded(
              child: Text(title, style: CatchTextStyles.titleL(context)),
            ),
            const SizedBox(width: CatchSpacing.s2),
            badge,
          ],
        ),
        const SizedBox(height: CatchSpacing.s2),
        Text(subtitle, style: CatchTextStyles.supporting(context)),
      ],
    );
  }
}
