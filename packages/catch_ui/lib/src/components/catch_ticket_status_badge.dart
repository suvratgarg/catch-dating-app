import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_ticket_status_badge_tone.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

class CatchTicketStatusBadge extends StatelessWidget {
  const CatchTicketStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.tone = CatchTicketStatusBadgeTone.soft,
  });

  final String label;
  final Color color;
  final CatchTicketStatusBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final dark = tone == CatchTicketStatusBadgeTone.dark;
    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: dark
          ? t.darkPillFill
          : color.withValues(alpha: CatchOpacity.subtleFill),
      borderWidth: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: dark ? CatchSpacing.s3 : CatchSpacing.s2,
          vertical: dark ? CatchSpacing.s1 : CatchSpacing.s1,
        ),
        child: Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.monoLabel(
            context,
            color: dark ? t.darkPillInk : color,
          ),
        ),
      ),
    );
  }
}
