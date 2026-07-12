import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_icon.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Branded fallback for Flutter framework build errors.
///
/// This intentionally avoids higher-level app primitives that depend on
/// complex layout or provider state. Error fallbacks must be boring and robust:
/// if the normal widget tree is already failing, this view still needs to paint.
class CatchFrameworkErrorView extends StatelessWidget {
  const CatchFrameworkErrorView({
    super.key,
    required this.details,
    this.showDebugDetails = kDebugMode,
  });

  final FlutterErrorDetails details;
  final bool showDebugDetails;

  @override
  Widget build(BuildContext context) {
    final tokens = _tokensOf(context);
    final debugText = details.exceptionAsString();

    return Material(
      color: tokens.bg,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(CatchSpacing.s6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.frameworkErrorMaxWidth,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(CatchRadius.lg),
                  border: Border.all(color: tokens.line),
                  boxShadow: CatchElevation.raised,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(CatchSpacing.s6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CatchErrorIcon(),
                      gapH18,
                      Text(
                        context
                            .l10n
                            .coreCatchFrameworkErrorViewTextSomethingWentWrong,
                        style: CatchTextStyles.headlineS(context),
                        textAlign: TextAlign.center,
                      ),
                      gapH8,
                      Text(
                        context
                            .l10n
                            .coreCatchFrameworkErrorViewTextThisScreenHitA,
                        style: CatchTextStyles.bodyLead(
                          context,
                          color: tokens.ink2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (showDebugDetails) ...[
                        gapH18,
                        CatchFrameworkErrorDebugDetails(details: debugText),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CatchFrameworkErrorDebugDetails extends StatefulWidget {
  const CatchFrameworkErrorDebugDetails({
    super.key,
    required this.details,
    this.initiallyExpanded = false,
  });

  final String details;
  final bool initiallyExpanded;

  @override
  State<CatchFrameworkErrorDebugDetails> createState() =>
      _CatchFrameworkErrorDebugDetailsState();
}

class _CatchFrameworkErrorDebugDetailsState
    extends State<CatchFrameworkErrorDebugDetails> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(CatchFrameworkErrorDebugDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpanded != oldWidget.initiallyExpanded) {
      _expanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _tokensOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _expanded,
          child: CatchSurface(
            tone: CatchSurfaceTone.transparent,
            radius: 0,
            borderWidth: 0,
            padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s2),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context
                        .l10n
                        .coreCatchFrameworkErrorViewTextDeveloperDetails,
                    style: CatchTextStyles.labelM(
                      context,
                      color: tokens.danger,
                    ),
                  ),
                ),
                gapW12,
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: CatchMotion.fast,
                  curve: CatchMotion.standardCurve,
                  child: Icon(
                    CatchIcons.chevronRightRounded,
                    color: tokens.danger,
                    size: CatchIcon.sm,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: CatchMotion.fast,
          curve: CatchMotion.standardCurve,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(CatchSpacing.s3),
                  decoration: BoxDecoration(
                    color: tokens.raised,
                    borderRadius: BorderRadius.circular(CatchRadius.md),
                    border: Border.all(color: tokens.line),
                  ),
                  child: Text(
                    widget.details,
                    style: CatchTextStyles.debugDetails(
                      context,
                      color: tokens.ink2,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

CatchTokens _tokensOf(BuildContext context) {
  return Theme.of(context).extension<CatchTokens>() ??
      CatchTokens.editorialLight;
}
