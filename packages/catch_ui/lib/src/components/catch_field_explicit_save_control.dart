import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Supporting metadata shown inside an explicit-save disclosure before its
/// commit bar. Validation remains a root-level `CatchFieldSupportRow`.
class CatchFieldExplicitSaveControl extends StatelessWidget {
  const CatchFieldExplicitSaveControl({
    super.key,
    this.supporting,
    this.feedback,
    this.secondaryAction,
  });

  final Widget? supporting;
  final Widget? feedback;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    void addChild(Widget child) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: CatchSpacing.s2));
      }
      children.add(child);
    }

    if (supporting case final supporting?) {
      addChild(Align(alignment: Alignment.centerRight, child: supporting));
    }
    if (feedback case final feedback?) addChild(feedback);
    if (secondaryAction case final secondaryAction?) {
      addChild(secondaryAction);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
