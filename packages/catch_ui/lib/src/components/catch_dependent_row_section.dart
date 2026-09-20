import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope_mode.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope_variant.dart';
import 'package:catch_ui/src/components/catch_section_surface.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Internal renderer for Section's conditional configuration recipe.
/// The leading and descendants share geometry; tint signals attachment without
/// adding another perimeter or claiming that a dependency is an equal peer.
class CatchDependentRowSection extends StatelessWidget {
  const CatchDependentRowSection({
    super.key,
    required this.leading,
    required this.children,
    this.footer,
    this.states = const {},
  });

  final CatchField leading;
  final List<CatchField> children;
  final Widget? footer;
  final Set<WidgetState> states;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: CatchSectionSurface.fieldRows(
        padding: EdgeInsets.zero,
        states: states,
        child: CatchFieldGeometryScope(
          gutterOwnership: CatchFieldGeometryScopeMode.field,
          contentInsets: const EdgeInsets.symmetric(
            horizontal: CatchFieldTokens.rowHorizontalPadding,
          ),
          interactionOutsets: EdgeInsets.zero,
          exactBounds: true,
          interactionShape: CatchFieldGeometryScopeVariant.sectionClipped,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              leading,
              if (children.isNotEmpty || footer != null)
                ColoredBox(
                  color: tokens.bg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...children,
                      if (footer case final footer?)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            CatchFieldTokens.rowHorizontalPadding,
                            CatchFieldTokens.containedSectionFooterTopPadding,
                            CatchFieldTokens.rowHorizontalPadding,
                            CatchFieldTokens.rowVerticalPadding,
                          ),
                          child: DefaultTextStyle.merge(
                            style: CatchTextStyles.supporting(
                              context,
                              color: tokens.ink2,
                            ),
                            child: footer,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
