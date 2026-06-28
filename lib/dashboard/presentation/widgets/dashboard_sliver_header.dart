import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';

class DashboardSliverHeader extends CatchSliverHeader {
  DashboardSliverHeader({
    required String eyebrow,
    required String title,
    List<Widget> actions = const <Widget>[],
  }) : super(
         title: _buildDashboardHeaderContent(
           eyebrow: eyebrow,
           title: title,
           actions: actions,
         ),
       );
}

Widget _buildDashboardHeaderContent({
  required String eyebrow,
  required String title,
  required List<Widget> actions,
}) {
  return Builder(
    builder: (context) {
      final t = CatchTokens.of(context);

      return Material(
        color: t.bg,
        child: Padding(
          padding: CatchInsets.screenTitleBlockCompact,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.kicker(context, color: t.ink3),
                    ),
                    gapH2,
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.headline(context),
                    ),
                  ],
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(width: CatchSpacing.s3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [for (final action in actions) action],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
