import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:flutter/material.dart';

/// Self-contained browse header for tab surfaces with scope, title, search,
/// and optional actions in one composable module.
class CatchBrowseHeader extends StatelessWidget {
  const CatchBrowseHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.searchActive,
    required this.searchField,
    required this.onOpenSearch,
    this.leading,
    this.actions = const [],
    this.searchActionVisible = true,
    this.searchTooltip = 'Search',
    this.searchSemanticLabel,
    this.backgroundColor,
    this.padding = const EdgeInsets.fromLTRB(
      CatchSpacing.s5,
      CatchSpacing.s4,
      CatchSpacing.s5,
      CatchSpacing.s3,
    ),
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool searchActive;
  final Widget searchField;
  final VoidCallback onOpenSearch;
  final bool searchActionVisible;
  final String searchTooltip;
  final String? searchSemanticLabel;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  static const double _contentHeight = CatchLayout.browseHeaderContentHeight;
  static const double _searchExtent = CatchLayout.browseHeaderSearchExtent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    // Clamp text scaling inside the header. The 60 px content slot fits
    // title + subtitle at scale 1.0; above ~1.15 the subtitle overflows.
    // We clamp to keep the layout intact while still honouring the user's
    // larger preference up to that ceiling.
    final ambientScaler = MediaQuery.textScalerOf(context);
    final clampedFactor = ambientScaler.scale(1.0).clamp(0.85, 1.15);
    final clampedScaler = TextScaler.linear(clampedFactor);
    final contentHeight = _contentHeight * clampedFactor;

    return ColoredBox(
      color: backgroundColor ?? t.bg,
      child: Padding(
        padding: padding,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: contentHeight,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: searchActive ? 1 : 0),
                  duration: CatchMotion.base,
                  curve: CatchMotion.standardCurve,
                  builder: (context, progress, _) {
                    return Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        ExcludeSemantics(
                          excluding: progress > 0.5,
                          child: IgnorePointer(
                            ignoring: progress > 0.02,
                            child: Opacity(
                              opacity: (1 - (progress * 1.5)).clamp(0.0, 1.0),
                              child: _TitleLayout(
                                title: title,
                                subtitle: subtitle,
                                leading: leading,
                                actions: actions,
                                reserveSearchAction: searchActionVisible,
                              ),
                            ),
                          ),
                        ),
                        if (searchActionVisible || progress > 0)
                          _MorphingSearchControl(
                            progress: progress,
                            maxWidth: constraints.maxWidth,
                            searchField: searchField,
                            onOpenSearch: onOpenSearch,
                            tooltip: searchTooltip,
                            semanticLabel: searchSemanticLabel ?? searchTooltip,
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TitleLayout extends StatelessWidget {
  const _TitleLayout({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.reserveSearchAction,
    this.leading,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool reserveSearchAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, gapW12],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.headline(context),
              ),
              gapH4,
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.supporting(context),
              ),
            ],
          ),
        ),
        for (final action in actions) ...[gapW8, action],
        if (reserveSearchAction) ...[
          gapW8,
          const SizedBox.square(dimension: CatchBrowseHeader._searchExtent),
        ],
      ],
    );
  }
}

class _MorphingSearchControl extends StatelessWidget {
  const _MorphingSearchControl({
    required this.progress,
    required this.maxWidth,
    required this.searchField,
    required this.onOpenSearch,
    required this.tooltip,
    required this.semanticLabel,
  });

  final double progress;
  final double maxWidth;
  final Widget searchField;
  final VoidCallback onOpenSearch;
  final String tooltip;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final width =
        CatchBrowseHeader._searchExtent +
        ((maxWidth - CatchBrowseHeader._searchExtent) * progress);
    final fieldOpacity = ((progress - 0.12) / 0.88).clamp(0.0, 1.0);
    final showField = progress > 0.06;

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: width,
        height: CatchBrowseHeader._searchExtent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          child: showField
              ? Opacity(opacity: fieldOpacity, child: searchField)
              : Tooltip(
                  message: tooltip,
                  child: Semantics(
                    button: true,
                    label: semanticLabel,
                    child: IconBtn(
                      size: CatchBrowseHeader._searchExtent,
                      onTap: onOpenSearch,
                      background: t.raised,
                      child: Icon(
                        CatchIcons.search,
                        size: CatchIcon.control,
                        color: t.ink,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
