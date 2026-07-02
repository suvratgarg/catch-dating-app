import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

@immutable
class HostOrganizerPayoutPromptState {
  const HostOrganizerPayoutPromptState._({
    required this.visible,
    required this.loading,
    required this.title,
    required this.message,
  });

  const HostOrganizerPayoutPromptState.hidden()
    : this._(visible: false, loading: false, title: '', message: '');

  const HostOrganizerPayoutPromptState.loading()
    : this._(
        visible: true,
        loading: true,
        title: 'Checking payout status',
        message:
            'We are checking whether this organizer can collect paid bookings.',
      );

  const HostOrganizerPayoutPromptState.error()
    : this._(
        visible: true,
        loading: false,
        title: 'Payout status needs attention',
        message: 'Open payouts to retry status checks and continue setup.',
      );

  const HostOrganizerPayoutPromptState.setupRequired()
    : this._(
        visible: true,
        loading: false,
        title: 'Connect payouts to get paid',
        message: "Paid events can't collect until Stripe is set up.",
      );

  final bool visible;
  final bool loading;
  final String title;
  final String message;
}

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
                Text(state.title, style: CatchTextStyles.labelL(context)),
                gapH2,
                Text(
                  state.message,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                if (!state.loading) ...[
                  gapH8,
                  SizedBox(
                    width: CatchLayout.hostPayoutSetupButtonWidth,
                    child: CatchButton(
                      label: 'Set up payouts',
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
