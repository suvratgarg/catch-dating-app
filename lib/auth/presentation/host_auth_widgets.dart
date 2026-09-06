import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// The outlined lower-stage container shared by every Catch Host auth state.
class HostAuthCard extends StatelessWidget {
  const HostAuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CatchSurface.card(
      borderRole: CatchBorderRole.boundary,
      boxShadow: CatchElevation.none,
      padding: CatchInsets.content,
      child: child,
    );
  }
}

class HostAuthHeader extends StatelessWidget {
  const HostAuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: CatchTextStyles.sectionTitle(context)),
        gapH4,
        Text(
          subtitle,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
      ],
    );
  }
}

/// A non-interactive primary action surface that preserves the button's
/// geometry while an authentication request is in flight.
class HostAuthProgressButton extends StatelessWidget {
  const HostAuthProgressButton({
    super.key,
    required this.label,
    this.variant = CatchButtonVariant.primary,
  });

  final String label;
  final CatchButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Semantics(
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: CatchButton(
          label: label,
          icon: SizedBox.square(
            dimension: CatchIcon.sm,
            child: CatchLoadingIndicator(
              color: variant == CatchButtonVariant.primary
                  ? t.primaryInk
                  : t.ink,
            ),
          ),
          onPressed: null,
          variant: variant,
          isInteractive: false,
          fullWidth: true,
          size: CatchButtonSize.lg,
          shape: CatchButtonShape.rounded,
        ),
      ),
    );
  }
}
