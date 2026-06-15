import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_expanding_search.dart';
import 'package:flutter/material.dart';

/// Self-contained browse header for tab surfaces with scope, title, search,
/// and optional actions in one composable module.
class CatchBrowseHeader extends StatelessWidget {
  const CatchBrowseHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.searchActive,
    required this.onOpenSearch,
    this.searchValue = '',
    this.onSearchChanged,
    this.searchPlaceholder = 'Search',
    this.onCloseSearch,
    this.onSearchSubmitted,
    this.onSearchFocusChanged,
    this.searchAutofocus = false,
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
  final VoidCallback onOpenSearch;
  final String searchValue;
  final ValueChanged<String>? onSearchChanged;
  final String searchPlaceholder;
  final VoidCallback? onCloseSearch;
  final ValueChanged<String>? onSearchSubmitted;
  final ValueChanged<bool>? onSearchFocusChanged;
  final bool searchAutofocus;
  final bool searchActionVisible;
  final String searchTooltip;
  final String? searchSemanticLabel;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  static const double _contentHeight = CatchLayout.browseHeaderContentHeight;

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
                          CatchExpandingSearch(
                            progress: progress,
                            maxWidth: constraints.maxWidth,
                            value: searchValue,
                            onChanged: onSearchChanged,
                            placeholder: searchPlaceholder,
                            onOpenSearch: onOpenSearch,
                            onCloseSearch: onCloseSearch,
                            onSubmitted: onSearchSubmitted,
                            onFocusChanged: onSearchFocusChanged,
                            autofocus: searchAutofocus,
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
          const SizedBox.square(
            dimension: CatchLayout.browseHeaderSearchExtent,
          ),
        ],
      ],
    );
  }
}
