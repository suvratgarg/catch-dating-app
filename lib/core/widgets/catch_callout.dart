import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/src/catch_inline_message_surface.dart';
import 'package:flutter/material.dart';

enum CatchCalloutTone { primary, success, warning, danger, neutral }

/// Design-system `Callout` (`components/core/Callout`): a quiet inline banner for
/// a note, tip, or reassurance — a tinted tone wash (or a neutral hairline box)
/// with a leading glyph, optional bold [title], and [message] body. Use for
/// inline notes; not for inline form errors (use the field's error slot) or
/// action cards (those carry a button).
class CatchCallout extends StatelessWidget {
  const CatchCallout({
    super.key,
    required this.message,
    this.icon,
    this.tone = CatchCalloutTone.primary,
    this.title,
  });

  final String message;

  /// Leading glyph; defaults to a sparkle. Pass a filled Phosphor glyph for the
  /// design-system filled treatment.
  final IconData? icon;
  final CatchCalloutTone tone;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isNeutral = tone == CatchCalloutTone.neutral;
    final toneColor = switch (tone) {
      CatchCalloutTone.primary => t.primary,
      CatchCalloutTone.success => t.success,
      CatchCalloutTone.warning => t.warning,
      CatchCalloutTone.danger => t.danger,
      CatchCalloutTone.neutral => t.ink2,
    };

    return CatchInlineMessageSurface(
      title: title,
      message: message,
      icon: icon ?? CatchIcons.sparkle,
      iconColor: isNeutral ? t.ink2 : toneColor,
      backgroundColor: isNeutral
          ? null
          : Color.alphaBlend(
              toneColor.withValues(alpha: CatchOpacity.calloutFill),
              t.surface,
            ),
      borderColor: isNeutral ? t.line : null,
    );
  }
}
