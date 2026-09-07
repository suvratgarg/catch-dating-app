import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_contract_field_constraints.dart';
import 'package:catch_ui/src/components/catch_field_copy.dart';
import 'package:catch_ui/src/components/catch_field_motion.dart';
import 'package:catch_ui/src/components/catch_field_status.dart';
import 'package:catch_ui/src/components/catch_field_status_indicator.dart';
import 'package:catch_ui/src/components/catch_field_toggle.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_control_shell.dart';
import 'package:flutter/material.dart';

class CatchFieldTrailing extends StatelessWidget {
  /// Shared clear-action allocation for the native target and its row slot.
  static BoxConstraints get clearTargetConstraints =>
      CatchControlMetrics.squareConstraints(CatchSpacing.s6);

  factory CatchFieldTrailing.custom({
    Key? key,
    required Widget child,
    Color? color,
    double topPadding = CatchSpacing.micro2,
  }) {
    return CatchFieldTrailing._(
      key: key,
      topPadding: topPadding,
      builder: (context) {
        final t = CatchTokens.of(context);
        final resolvedColor = color ?? t.ink3;
        return IconTheme(
          data: IconThemeData(color: resolvedColor, size: CatchIcon.md),
          child: DefaultTextStyle.merge(
            style: CatchTextStyles.bodyLead(context, color: resolvedColor),
            child: child,
          ),
        );
      },
    );
  }

  factory CatchFieldTrailing.valueText({
    Key? key,
    required String text,
    int maxLines = 1,
    double topPadding = CatchSpacing.micro2,
  }) {
    return CatchFieldTrailing._(
      key: key,
      topPadding: topPadding,
      builder: (context) {
        final t = CatchTokens.of(context);
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.fieldTrailingValueMaxWidth,
          ),
          child: Text(
            text,
            textAlign: TextAlign.right,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.fieldRowValue(
              context,
              color: t.ink2,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }

  factory CatchFieldTrailing.fixedChevron({
    Key? key,
    Color? color,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => Icon(
      CatchIcons.chevronRightRounded,
      size: CatchFieldTokens.disclosureGlyphExtent,
      color: color ?? CatchTokens.of(context).ink3,
    ),
  );

  factory CatchFieldTrailing.rotatingChevron({
    Key? key,
    required bool open,
    Color? color,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => AnimatedRotation(
      turns: open ? 0.5 : 0,
      duration: catchFieldMotionDuration(context, CatchMotion.base),
      curve: CatchMotion.standardCurve,
      child: Icon(
        CatchIcons.expandMoreRounded,
        size: CatchFieldTokens.disclosureGlyphExtent,
        color: color ?? CatchTokens.of(context).ink3,
      ),
    ),
  );

  factory CatchFieldTrailing.toggle({
    required CatchFieldCopy copy,
    Key? key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    CatchContractFieldConstraints? contract,
    String? contractExemption,
    String? semanticLabel,
    CatchFieldStatus status = CatchFieldStatus.idle,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchFieldStatusIndicator(
          savingSemanticLabel: copy.savingSemanticLabel,
          savedSemanticLabel: copy.savedSemanticLabel,
          status: status,
          includeTrailingGap: true,
        ),
        CatchFieldToggle(
          value: value,
          contract: contract,
          contractExemption: contractExemption,
          semanticLabel: semanticLabel,
          onChanged: onChanged,
        ),
      ],
    ),
  );

  factory CatchFieldTrailing.status({
    required CatchFieldCopy copy,
    Key? key,
    required CatchFieldStatus status,
    double topPadding = 0,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => CatchFieldStatusIndicator(
      savingSemanticLabel: copy.savingSemanticLabel,
      savedSemanticLabel: copy.savedSemanticLabel,
      status: status,
    ),
  );

  factory CatchFieldTrailing.clear({
    Key? key,
    required String tooltip,
    required VoidCallback onPressed,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.standard,
      padding: EdgeInsets.zero,
      constraints: clearTargetConstraints,
      style: IconButton.styleFrom(
        minimumSize: clearTargetConstraints.smallest,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(
        CatchIcons.clearCircle,
        size: CatchFieldTokens.largeGlyphExtent,
        color: CatchTokens.of(context).ink3,
      ),
      onPressed: onPressed,
    ),
  );

  factory CatchFieldTrailing.valid({
    Key? key,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => Icon(
      CatchIcons.checkCircle,
      size: CatchIcon.md,
      color: CatchTokens.of(context).success,
    ),
  );

  const CatchFieldTrailing._({
    super.key,
    required this.builder,
    this.topPadding = CatchSpacing.micro2,
  });

  final WidgetBuilder builder;
  final double topPadding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: topPadding),
    child: builder(context),
  );
}
