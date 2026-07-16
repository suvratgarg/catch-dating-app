import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchDividerRole { section, fieldRow }

class CatchDivider extends StatelessWidget {
  const CatchDivider({
    super.key,
    this.role = CatchDividerRole.fieldRow,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  });

  const CatchDivider.section({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  }) : role = CatchDividerRole.section;

  const CatchDivider.fieldRow({
    super.key,
    this.indent = CatchLayout.fieldRowTextLaneInset,
    this.endIndent = 0,
    this.color,
  }) : role = CatchDividerRole.fieldRow;

  final CatchDividerRole role;
  final double indent;
  final double endIndent;
  final Color? color;

  static Color colorFor(CatchTokens tokens, CatchDividerRole role) {
    return switch (role) {
      CatchDividerRole.section => tokens.line,
      CatchDividerRole.fieldRow => tokens.line,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
        child: ColoredBox(
          color: color ?? colorFor(tokens, role),
          child: const SizedBox(height: CatchStroke.hairline),
        ),
      ),
    );
  }
}
