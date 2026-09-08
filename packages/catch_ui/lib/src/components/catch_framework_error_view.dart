import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_framework_error_debug_details.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_error_icon.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Already-localized recovery and diagnostic labels supplied by the app.
class CatchFrameworkErrorCopy {
  const CatchFrameworkErrorCopy({
    required this.title,
    required this.message,
    required this.debugDetailsLabel,
  });

  final String title;
  final String message;
  final String debugDetailsLabel;
}

/// Branded fallback for Flutter framework build errors.
///
/// This intentionally avoids higher-level app primitives that depend on
/// complex layout or provider state. Error fallbacks must be boring and robust:
/// if the normal widget tree is already failing, this view still needs to paint.
class CatchFrameworkErrorView extends StatelessWidget {
  const CatchFrameworkErrorView({
    super.key,
    required this.details,
    required this.copy,
    this.showDebugDetails = kDebugMode,
  });

  final FlutterErrorDetails details;
  final CatchFrameworkErrorCopy copy;
  final bool showDebugDetails;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<CatchTokens>() ??
        CatchTokens.editorialLight;
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
                        copy.title,
                        style: CatchTextStyles.headlineS(context),
                        textAlign: TextAlign.center,
                      ),
                      gapH8,
                      Text(
                        copy.message,
                        style: CatchTextStyles.bodyLead(
                          context,
                          color: tokens.ink2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (showDebugDetails) ...[
                        gapH18,
                        CatchFrameworkErrorDebugDetails(
                          details: debugText,
                          label: copy.debugDetailsLabel,
                        ),
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
