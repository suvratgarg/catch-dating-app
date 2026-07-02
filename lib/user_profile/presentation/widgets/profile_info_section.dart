import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;

const profileTabBodyPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s5,
  CatchSpacing.micro18,
  CatchSpacing.s5,
  CatchSpacing.s7,
);

class ProfileInfoSection extends StatelessWidget {
  const ProfileInfoSection({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.grouped = false,
    this.first = false,
    this.fullBleedRows = false,
  });

  final List<Widget> children;
  final String? title;
  final String? subtitle;
  final bool grouped;
  final bool first;
  final bool fullBleedRows;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final t = CatchTokens.of(context);
    final tiles = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      tiles.add(
        ProfileInfoRowFrame(fullBleed: fullBleedRows, child: children[i]),
      );
      if (grouped && i < children.length - 1) {
        tiles.add(
          Divider(
            height: 1,
            indent: CatchSpacing.s8,
            endIndent: CatchSpacing.s8,
            color: t.line.withValues(alpha: CatchOpacity.fieldRowDivider),
          ),
        );
      }
    }

    final tileList = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: tiles,
    );
    if (grouped && title != null) {
      return CatchSection.divided(
        title: title,
        count: subtitle,
        first: first,
        bodyGap: CatchSpacing.micro10,
        child: tileList,
      );
    }

    final body = grouped
        ? CatchSurface(
            borderColor: t.line,
            padding: CatchInsets.contentHorizontal,
            child: tileList,
          )
        : tileList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          gapH16,
          Padding(
            padding: EdgeInsets.only(
              left: grouped ? CatchSpacing.s1 : 0,
              bottom: CatchSpacing.micro2,
            ),
            child: Text(title!, style: CatchTextStyles.labelL(context)),
          ),
          gapH8,
        ],
        body,
      ],
    );
  }
}

class ProfileInfoRowFrame extends StatelessWidget {
  const ProfileInfoRowFrame({
    super.key,
    required this.fullBleed,
    required this.child,
  });

  final bool fullBleed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!fullBleed) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) return child;

        final mediaWidth = MediaQuery.sizeOf(context).width;
        final targetWidth = math.min(
          mediaWidth,
          constraints.maxWidth + CatchSpacing.screenPx * 2,
        );
        if (targetWidth <= constraints.maxWidth) return child;

        return OverflowBox(
          minWidth: targetWidth,
          maxWidth: targetWidth,
          fit: OverflowBoxFit.deferToChild,
          child: SizedBox(width: targetWidth, child: child),
        );
      },
    );
  }
}
