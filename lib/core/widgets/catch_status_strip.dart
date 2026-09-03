import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:flutter/material.dart';

/// Durable context, not a queued notification or a mutation failure.
/// Callers supply truthful state and actions; screen owners choose placement.
@immutable
class CatchStatusStripData {
  const CatchStatusStripData({
    required this.id,
    required this.label,
    required this.message,
    required this.icon,
    required this.color,
    this.actions = const [],
  });

  final String id;
  final String label;
  final String message;
  final IconData icon;
  final Color color;
  final List<CatchStatusStripAction> actions;
}

@immutable
class CatchStatusStripAction {
  const CatchStatusStripAction({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  /// Visible copy for a text action; accessible tooltip for an icon action.
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
}

/// Publishes context without drawing it. Canonical screen owners consume this
/// scope once, below their title and optional primary rail, and clear it for
/// nested content. The app publishes connectivity above the route navigator;
/// route-specific rehearsal context is supplied to its scaffold's typed slot.
class CatchStatusStripScope extends InheritedWidget {
  const CatchStatusStripScope({
    super.key,
    required this.statuses,
    required super.child,
  });

  final List<CatchStatusStripData> statuses;

  static List<CatchStatusStripData> of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CatchStatusStripScope>()
          ?.statuses ??
      const [];

  @override
  bool updateShouldNotify(CatchStatusStripScope oldWidget) =>
      statuses != oldWidget.statuses;
}

/// Full-width persistent header bands with common icon, label/detail and action
/// lanes. No timer, close control, overlay positioning or business-state reads.
/// Intrinsic height lets the layout owner pin the real content, including
/// wrapping translations and large text, without an estimated header extent.
class CatchStatusStrip extends StatelessWidget {
  const CatchStatusStrip({super.key, required this.statuses});

  final List<CatchStatusStripData> statuses;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final status in statuses)
          Semantics(
            key: ValueKey('status_strip.${status.id}'),
            container: true,
            liveRegion: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _background(t.bg, status.color),
                border: Border(
                  bottom: BorderSide(
                    color: status.color.withValues(
                      alpha: CatchOpacity.lightOverlayBorder,
                    ),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchSpacing.screenPx,
                  vertical: CatchSpacing.s2,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final foreground = _readableAccent(t, status.color);
                    final stacked =
                        MediaQuery.textScalerOf(context).scale(1) >= 1.4 ||
                        constraints.maxWidth <
                            CatchLayout.statusStripInlineMinWidth;
                    final identity = Row(
                      children: [
                        Icon(
                          status.icon,
                          size: CatchIcon.md,
                          color: status.color,
                        ),
                        const SizedBox(width: CatchSpacing.micro10),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                status.label.toUpperCase(),
                                style: CatchTextStyles.kicker(
                                  context,
                                  color: foreground,
                                ),
                              ),
                              const SizedBox(height: CatchSpacing.s1),
                              Text(
                                status.message,
                                style: CatchTextStyles.supporting(
                                  context,
                                  color: foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                    final actions = Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: CatchSpacing.s1,
                      children: [
                        for (final action in status.actions)
                          if (action.icon != null)
                            CatchIconButton.icon(
                              icon: action.icon!,
                              tooltip: action.label,
                              onTap: action.onPressed,
                              accent: status.color,
                              variant: CatchIconButtonVariant.plain,
                            )
                          else
                            CatchTextButton(
                              label: action.label,
                              onPressed: action.onPressed,
                              foregroundColor: foreground,
                              minimumSize: const Size.square(
                                CatchLayout.iconButtonSize,
                              ),
                            ),
                      ],
                    );
                    return ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: CatchSpacing.s12,
                      ),
                      child: stacked
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                identity,
                                if (status.actions.isNotEmpty) ...[
                                  const SizedBox(height: CatchSpacing.s2),
                                  actions,
                                ],
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: identity),
                                if (status.actions.isNotEmpty) ...[
                                  const SizedBox(width: CatchSpacing.s2),
                                  actions,
                                ],
                              ],
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  static Color _background(Color background, Color accent) => Color.alphaBlend(
    accent.withValues(alpha: CatchOpacity.tabBarPillFill),
    background,
  );

  // Semantic warning colors are suitable accents, but not necessarily small
  // text colors. Retain the hue while bringing copy/actions to 4.5:1 against
  // the actual tint, including caller-provided accents and both themes.
  static Color _readableAccent(CatchTokens tokens, Color accent) {
    final background = _background(tokens.bg, accent);
    final backgroundLuminance = background.computeLuminance() + 0.05;
    for (var step = 0; step <= 10; step++) {
      final candidate = Color.alphaBlend(
        Color.lerp(accent, tokens.ink, step / 10)!,
        background,
      );
      final luminance = candidate.computeLuminance() + 0.05;
      final contrast = luminance > backgroundLuminance
          ? luminance / backgroundLuminance
          : backgroundLuminance / luminance;
      if (contrast >= 4.5) return candidate;
    }
    return tokens.ink;
  }
}
