import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';

class MapOverlayControls extends StatelessWidget {
  const MapOverlayControls({super.key, this.trailing, this.below, this.onBack});

  final Widget? trailing;
  final Widget? below;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final below = this.below;

    return Positioned(
      top: CatchSpacing.s4,
      left: CatchSpacing.s4,
      right: CatchSpacing.s4,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CatchIconAction(
                  icon: CatchIcons.arrowBackIosNewRounded,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  backgroundColor: CatchTokens.of(context).surface.withValues(
                    alpha: CatchOpacity.mapOverlayChromeFill,
                  ),
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                ?trailing,
              ],
            ),
            if (below != null) ...[
              const SizedBox(height: CatchSpacing.s3),
              below,
            ],
          ],
        ),
      ),
    );
  }
}
