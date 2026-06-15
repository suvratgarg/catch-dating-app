import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:flutter/material.dart';

/// Handoff `ExpandingSearch`: an app-bar magnifier that grows into the shared
/// raised-pill search field.
class CatchExpandingSearch extends StatelessWidget {
  const CatchExpandingSearch({
    super.key,
    required this.progress,
    required this.maxWidth,
    this.value = '',
    this.onChanged,
    this.placeholder = 'Search',
    this.onOpenSearch,
    this.onCloseSearch,
    this.onSubmitted,
    this.onFocusChanged,
    this.autofocus = false,
    this.tooltip = 'Search',
    this.semanticLabel,
    this.collapsedExtent = CatchLayout.browseHeaderSearchExtent,
  });

  final double progress;
  final double maxWidth;
  final String value;
  final ValueChanged<String>? onChanged;
  final String placeholder;
  final VoidCallback? onOpenSearch;
  final VoidCallback? onCloseSearch;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChanged;
  final bool autofocus;
  final String tooltip;
  final String? semanticLabel;
  final double collapsedExtent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final clampedProgress = progress.clamp(0.0, 1.0);
    final width =
        collapsedExtent + ((maxWidth - collapsedExtent) * clampedProgress);
    final fieldOpacity = ((clampedProgress - 0.12) / 0.88).clamp(0.0, 1.0);
    final showField = clampedProgress > 0.06;

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: width,
        height: collapsedExtent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          child: showField
              ? Opacity(
                  opacity: fieldOpacity,
                  child: CatchSearchField(
                    value: value,
                    onChanged: onChanged,
                    placeholder: placeholder,
                    autofocus: autofocus,
                    onSubmitted: onSubmitted,
                    onFocusChanged: onFocusChanged,
                    semanticLabel: semanticLabel ?? placeholder,
                    emptyTrailingIcon: CatchIcons.close,
                    emptyTrailingTooltip: 'Close search',
                    onEmptyTrailingPressed: onCloseSearch,
                  ),
                )
              : Tooltip(
                  message: tooltip,
                  child: Semantics(
                    button: true,
                    label: semanticLabel ?? tooltip,
                    child: IconBtn(
                      size: collapsedExtent,
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
