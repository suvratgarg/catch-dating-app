import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// A readable record: heading, optional evidence/context, and optional prose.
///
/// Unlike a field, none of these slots represents an editable value. A parent
/// section owns grouping and dividers. Only records with a destination receive
/// press semantics and a disclosure indicator. All text has natural height.
class CatchRecordRow extends StatelessWidget {
  const CatchRecordRow({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    this.metadata,
    this.facts = const [],
    this.description,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Color? color;
  final String? metadata;

  /// Short, equally important facts (for example time/place and attendance).
  /// These use readable secondary text, not the smaller provenance caption.
  final List<String> facts;
  final String? description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? CatchTokens.of(context).ink2;
    return CatchRowPressSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: CatchRecordTokens.verticalPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: CatchSurface(
                width: CatchRecordTokens.avatarExtent,
                height: CatchRecordTokens.avatarExtent,
                radius: CatchRadius.pill,
                backgroundColor: tone.withValues(
                  alpha: CatchOpacity.subtleFill,
                ),
                child: Icon(icon, size: CatchIcon.md, color: tone),
              ),
            ),
            const SizedBox(width: CatchRecordTokens.leadingGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: CatchTextStyles.recordTitle(context)),
                  if (metadata case final text? when text.isNotEmpty) ...[
                    const SizedBox(height: CatchRecordTokens.titleGap),
                    Text(text, style: CatchTextStyles.recordContext(context)),
                  ],
                  for (final fact in facts.where(
                    (text) => text.isNotEmpty,
                  )) ...[
                    const SizedBox(height: CatchRecordTokens.titleGap),
                    Text(
                      fact,
                      style: CatchTextStyles.supporting(
                        context,
                        color: CatchTokens.of(context).ink2,
                      ),
                    ),
                  ],
                  if (description case final text? when text.isNotEmpty) ...[
                    const SizedBox(height: CatchRecordTokens.bodyGap),
                    Text(text, style: CatchTextStyles.recordBody(context)),
                  ],
                ],
              ),
            ),
            if (onTap != null) ...[
              gapW8,
              ExcludeSemantics(
                child: Icon(
                  CatchIcons.chevronRightRounded,
                  size: CatchIcon.sm,
                  color: CatchTokens.of(context).ink3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
