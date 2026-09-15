import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_section_header.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
import 'package:catch_ui/src/primitives/catch_kicker_text.dart';
import 'package:flutter/widgets.dart';

/// Shared readable lane within a full-width page or local pane.
double catchSectionContentGutter(double width) =>
    math.max(CatchSpacing.screenPx, (width - CatchLayout.maxContentWidth) / 2);

/// Internal header boundary shared by row and non-row section recipes.
class CatchContentSectionHeader extends StatelessWidget {
  const CatchContentSectionHeader({
    super.key,
    this.title,
    this.count,
    this.trailing,
  });
  final String? title;
  final Object? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      CatchSectionHeader.kicker(
        title: title,
        count: count,
        trailing: trailing,
        color: CatchTokens.of(context).ink2,
        textVariant: CatchKickerTextVariant.fieldSection,
      ),
      const SizedBox(height: CatchFieldTokens.sectionRuleGap),
      const CatchDivider.section(),
    ],
  );
}

/// Non-row content has a readable inset and no shared row recognizer.
class CatchContentSection extends StatelessWidget {
  const CatchContentSection({
    super.key,
    required this.child,
    this.title,
    this.count,
    this.trailing,
  });
  final Widget child;
  final String? title;
  final Object? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      assert(constraints.hasBoundedWidth, 'Sections require a page or pane.');
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: catchSectionContentGutter(constraints.maxWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null || count != null || trailing != null) ...[
              CatchContentSectionHeader(
                title: title,
                count: count,
                trailing: trailing,
              ),
              const SizedBox(height: CatchSpacing.s3),
            ],
            child,
          ],
        ),
      );
    },
  );
}
