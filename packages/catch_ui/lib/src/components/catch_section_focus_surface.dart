import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope.dart';
import 'package:catch_ui/src/components/catch_field_interaction_shape.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/widgets.dart';

class CatchSectionFocusSurface extends StatefulWidget {
  const CatchSectionFocusSurface({
    super.key,
    required this.child,
    required this.padding,
    this.backgroundColor,
    this.borderColor,
    this.tone = CatchSurfaceTone.surface,
    this.emphasis = CatchSurfaceEmphasis.subtle,
    this.boxShadow,
    required this.focused,
    required this.hasError,
    this.fieldRows = false,
  });

  /// The single rounded clip that owns every contained row's external corners.
  ///
  /// Individual row press surfaces stay rectangular. Their top, middle,
  /// bottom, and single-row shapes are produced only where this group clip
  /// intersects the active row.
  static const rowGroupClipKey = ValueKey<String>(
    'catch-section-row-group-clip',
  );

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final CatchSurfaceTone tone;
  final CatchSurfaceEmphasis emphasis;
  final List<BoxShadow>? boxShadow;
  final bool focused;
  final bool hasError;
  final bool fieldRows;

  @override
  State<CatchSectionFocusSurface> createState() =>
      _CatchSectionFocusSurfaceState();
}

class _CatchSectionFocusSurfaceState extends State<CatchSectionFocusSurface> {
  bool _descendantFocused = false;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    if (widget.fieldRows) {
      final duration = MediaQuery.maybeOf(context)?.disableAnimations == true
          ? Duration.zero
          : CatchFieldTokens.standard;
      final fieldContent = CatchFieldGeometryScope(
        gutterOwnership: CatchFieldGeometryScope.gutterOwnershipOf(context),
        // The section perimeter consumes one hairline of layout on every
        // edge. Active child chrome reclaims that exact horizontal inset so
        // both primitives paint on one coordinate instead of producing two
        // adjacent vertical strokes. Keep this contract here so direct users
        // of CatchSectionFocusSurface cannot bypass it.
        // This surface owns one rounded clip for the complete row group.
        // Descendant press, focus, edit, and disclosure chrome therefore stays
        // rectangular and receives only the external corners it touches.
        interactionShape: CatchFieldInteractionShape.sectionClipped,
        child: widget.child,
      );
      final sectionRadius = BorderRadius.circular(
        CatchFieldTokens.sectionRadius,
      );
      final border = widget.hasError
          ? CatchBorder.resolve(t, CatchBorderRole.danger)
          : widget.focused
          ? CatchBorder.resolve(t, CatchBorderRole.focus)
          : CatchBorder.resolve(
              t,
              CatchBorderRole.boundary,
              color: widget.borderColor,
            );
      return ClipRRect(
        key: CatchSectionFocusSurface.rowGroupClipKey,
        borderRadius: sectionRadius,
        clipBehavior: Clip.hardEdge,
        child: AnimatedContainer(
          duration: duration,
          curve: CatchFieldTokens.curve,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? t.surface,
            borderRadius: sectionRadius,
          ),
          // Paint the perimeter after the row tiles. Active edge rows overlap
          // this same perimeter geometry and first/last rows overlap their
          // internal hairlines, but neither may obscure the section-owned edge.
          foregroundDecoration: BoxDecoration(
            borderRadius: sectionRadius,
            border: border.all,
          ),
          child: Padding(
            // A decoration border contributes its dimensions to Container's
            // child layout; a foreground border does not. Preserve that exact
            // one-hairline content inset while moving only paint order forward.
            padding: const EdgeInsets.all(CatchStroke.hairline),
            child: Padding(padding: widget.padding, child: fieldContent),
          ),
        ),
      );
    }

    final effectiveFocused = widget.focused || _descendantFocused;
    final border = widget.hasError
        ? CatchBorder.resolve(t, CatchBorderRole.danger)
        : effectiveFocused
        ? CatchBorder.resolve(t, CatchBorderRole.focus)
        : widget.borderColor == null
        ? null
        : CatchBorder.resolve(
            t,
            CatchBorderRole.boundary,
            color: widget.borderColor,
          );
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _handleFocusChange,
      child: CatchSurface(
        padding: widget.padding,
        radius: CatchRadius.md,
        tone: widget.tone,
        emphasis: widget.emphasis,
        backgroundColor: widget.backgroundColor,
        borderSpec: border,
        boxShadow: effectiveFocused && !widget.hasError
            ? CatchElevation.focusRing(t)
            : widget.boxShadow,
        child: widget.child,
      ),
    );
  }

  void _handleFocusChange(bool focused) {
    if (_descendantFocused == focused) return;
    setState(() => _descendantFocused = focused);
  }
}
