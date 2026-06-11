import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
                      const _ErrorIcon(),
                      gapH18,
                      Text(
                        'Something went wrong',
                        style: CatchTextStyles.headlineS(context),
                        textAlign: TextAlign.center,
                      ),
                      gapH8,
                      Text(
                        'This screen hit a temporary app error. Please go back '
                        'or try again in a moment.',
                        style: CatchTextStyles.bodyLead(
                          context,
                          color: tokens.ink2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (showDebugDetails) ...[
                        gapH18,
                        _DebugDetails(details: debugText),
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

class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon();

  @override
  Widget build(BuildContext context) {
    final tokens = _tokensOf(context);

    return Align(
      child: Container(
        width: CatchLayout.frameworkErrorIconExtent,
        height: CatchLayout.frameworkErrorIconExtent,
        decoration: BoxDecoration(
          color: tokens.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(
          CatchIcons.errorOutlineRounded,
          color: tokens.danger,
          size: CatchLayout.frameworkErrorIconSize,
        ),
      ),
    );
  }
}

class _DebugDetails extends StatelessWidget {
  const _DebugDetails({required this.details});

  final String details;

  @override
  Widget build(BuildContext context) {
    final tokens = _tokensOf(context);

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        expansionTileTheme: const ExpansionTileThemeData(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ExpansionTile(
          title: Text(
            'Developer details',
            style: CatchTextStyles.labelM(context, color: tokens.danger),
          ),
          iconColor: tokens.danger,
          collapsedIconColor: tokens.danger,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(CatchSpacing.s3),
              decoration: BoxDecoration(
                color: tokens.raised,
                borderRadius: BorderRadius.circular(CatchRadius.md),
                border: Border.all(color: tokens.line),
              ),
              child: Text(
                details,
                style: CatchTextStyles.debugDetails(
                  context,
                  color: tokens.ink2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

CatchTokens _tokensOf(BuildContext context) {
  return Theme.of(context).extension<CatchTokens>() ?? CatchTokens.sunsetLight;
}
