import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_sheet_drag_indicator.dart';
import 'package:flutter/material.dart';

/// Presentation-only card preview and share action.
///
/// The caller owns capture, sharing state, platform export and error handling.
/// [onShare] receives the button context so an app adapter can anchor native UI.
class CatchShareCardSheet extends StatelessWidget {
  const CatchShareCardSheet({
    super.key,
    required this.card,
    required this.captureKey,
    required this.buttonLabel,
    required this.footnote,
    required this.onShare,
    this.isSharing = false,
    this.maxWidth = CatchLayout.richShareCardWidth,
  });

  static const cardPreviewKey = ValueKey('rich_share_card_sheet.card_preview');
  static const shareButtonKey = ValueKey('rich_share_card_sheet.share_button');

  final Widget card;
  final GlobalKey captureKey;
  final String buttonLabel;
  final String footnote;
  final ValueChanged<BuildContext> onShare;
  final bool isSharing;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: CatchSpacing.s4,
          right: CatchSpacing.s4,
          top: CatchSpacing.s4,
          bottom: MediaQuery.viewInsetsOf(context).bottom + CatchSpacing.s4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CatchSheetDragIndicator(),
            gapH16,
            RepaintBoundary(
              key: captureKey,
              child: ConstrainedBox(
                key: cardPreviewKey,
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: card,
              ),
            ),
            gapH12,
            Text(
              footnote,
              textAlign: TextAlign.center,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
            gapH16,
            Builder(
              builder: (buttonContext) => CatchButton(
                key: shareButtonKey,
                label: buttonLabel,
                fullWidth: true,
                isLoading: isSharing,
                icon: Icon(
                  CatchIcons.platformShare(
                    platform: Theme.of(context).platform,
                  ),
                ),
                onPressed: () => onShare(buttonContext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
