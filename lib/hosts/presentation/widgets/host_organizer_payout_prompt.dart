import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

@immutable
class HostOrganizerPayoutPromptState {
  const HostOrganizerPayoutPromptState._(this.kind);

  const HostOrganizerPayoutPromptState.hidden()
    : this._(HostOrganizerPayoutPromptKind.hidden);

  const HostOrganizerPayoutPromptState.loading()
    : this._(HostOrganizerPayoutPromptKind.loading);

  const HostOrganizerPayoutPromptState.error()
    : this._(HostOrganizerPayoutPromptKind.error);

  const HostOrganizerPayoutPromptState.setupRequired()
    : this._(HostOrganizerPayoutPromptKind.setupRequired);

  final HostOrganizerPayoutPromptKind kind;

  bool get visible => kind != HostOrganizerPayoutPromptKind.hidden;
  bool get loading => kind == HostOrganizerPayoutPromptKind.loading;
}

enum HostOrganizerPayoutPromptKind { hidden, loading, error, setupRequired }

class HostOrganizerPayoutPrompt extends StatelessWidget {
  const HostOrganizerPayoutPrompt({
    super.key,
    required this.state,
    required this.onManagePayouts,
  });

  final HostOrganizerPayoutPromptState state;
  final VoidCallback onManagePayouts;

  @override
  Widget build(BuildContext context) {
    if (!state.visible) return const SizedBox.shrink();

    final t = CatchTokens.of(context);
    final warningFill = Color.alphaBlend(
      t.warning.withValues(alpha: CatchOpacity.calloutFill),
      t.surface,
    );
    final title = switch (state.kind) {
      HostOrganizerPayoutPromptKind.loading =>
        context.l10n.hostsHostOrganizerPayoutPromptTitleCheckingPayoutStatus,
      HostOrganizerPayoutPromptKind.error =>
        context
            .l10n
            .hostsHostOrganizerPayoutPromptTitlePayoutStatusNeedsAttention,
      HostOrganizerPayoutPromptKind.setupRequired =>
        context.l10n.hostsHostOrganizerPayoutPromptTitleConnectPayoutsToGet,
      HostOrganizerPayoutPromptKind.hidden => '',
    };
    final message = switch (state.kind) {
      HostOrganizerPayoutPromptKind.loading =>
        context.l10n.hostsHostOrganizerPayoutPromptMessageWeAreCheckingWhether,
      HostOrganizerPayoutPromptKind.error =>
        context.l10n.hostsHostOrganizerPayoutPromptMessageOpenPayoutsToRetry,
      HostOrganizerPayoutPromptKind.setupRequired =>
        context.l10n.hostsHostOrganizerPayoutPromptMessagePaidEventsCanT,
      HostOrganizerPayoutPromptKind.hidden => '',
    };

    return CatchSurface(
      backgroundColor: warningFill,
      borderColor: Colors.transparent,
      radius: CatchRadius.md,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s4,
        vertical: CatchSpacing.s3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: CatchStroke.hairline),
            child: Icon(
              CatchIcons.warningAmberRounded,
              size: CatchIcon.md,
              color: t.warning,
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CatchTextStyles.labelL(context)),
                gapH2,
                Text(
                  message,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                if (!state.loading) ...[
                  gapH8,
                  SizedBox(
                    width: CatchLayout.hostPayoutSetupButtonWidth,
                    child: CatchButton(
                      label: context
                          .l10n
                          .hostsHostOrganizerPayoutPromptLabelSetUpPayouts,
                      size: CatchButtonSize.sm,
                      fullWidth: true,
                      onPressed: onManagePayouts,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
