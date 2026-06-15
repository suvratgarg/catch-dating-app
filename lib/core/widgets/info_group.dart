import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/info_row.dart';
import 'package:flutter/material.dart';

/// Handoff `CatchInfoGroup`: kicker plus full-strength group separator.
class CatchInfoGroup extends StatelessWidget {
  const CatchInfoGroup({
    super.key,
    this.title,
    this.first = false,
    this.rows = const [],
  });

  final String? title;
  final bool first;
  final List<CatchInfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final displayTitle = title?.trim();

    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : CatchLayout.infoGroupTopMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!first) Divider(color: t.line, height: CatchStroke.hairline),
          if (!first) const SizedBox(height: CatchLayout.infoGroupTopPadding),
          if (displayTitle != null && displayTitle.isNotEmpty) ...[
            CatchKicker(label: displayTitle, color: t.ink3),
            const SizedBox(height: CatchLayout.infoGroupTitleGap),
          ],
          Column(
            children: [
              for (var index = 0; index < rows.length; index++)
                rows[index].copyWith(divider: index > 0),
            ],
          ),
        ],
      ),
    );
  }
}
