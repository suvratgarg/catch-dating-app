part of 'event_success_feature_blocks.dart';

class ProgressRow extends StatelessWidget {
  const ProgressRow({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final double value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: CatchTextStyles.sectionTitle(context)),
            ),
            Text(detail, style: CatchTextStyles.labelL(context)),
          ],
        ),
        const SizedBox(height: CatchSpacing.s2),
        ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: t.raised,
            valueColor: AlwaysStoppedAnimation<Color>(t.primary),
          ),
        ),
      ],
    );
  }
}
