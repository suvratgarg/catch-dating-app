import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/bottom_sheet_grabber.dart';
import 'package:flutter/material.dart';

class CatchBottomSheetScaffold extends StatelessWidget {
  const CatchBottomSheetScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.action,
    this.keyboardSafe = false,
    this.padding,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? action;
  final bool keyboardSafe;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomInset = keyboardSafe
        ? MediaQuery.of(context).viewInsets.bottom
        : 0.0;
    final effectivePadding =
        padding ??
        EdgeInsets.fromLTRB(
          CatchSpacing.s4,
          CatchSpacing.s3,
          CatchSpacing.s4,
          bottomInset + CatchSpacing.s4,
        );

    return Padding(
      padding: effectivePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetGrabber(),
          if (title != null) ...[
            gapH16,
            Text(title!, style: CatchTextStyles.titleL(context)),
          ],
          if (subtitle != null) ...[
            gapH4,
            Text(
              subtitle!,
              style: CatchTextStyles.supporting(context, color: t.ink3),
            ),
          ],
          gapH16,
          child,
          if (action != null) ...[gapH16, action!],
        ],
      ),
    );
  }
}
