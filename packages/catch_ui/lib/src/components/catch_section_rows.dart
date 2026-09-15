import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field.dart';
import 'package:catch_ui/src/components/catch_field_activity_notification.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope_mode.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope_variant.dart';
import 'package:catch_ui/src/components/catch_field_motion.dart';
import 'package:catch_ui/src/components/catch_section_content.dart';
import 'package:catch_ui/src/components/catch_section_surface.dart';
import 'package:catch_ui/src/patterns/catch_row_viewport.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
import 'package:flutter/material.dart';

// Keep collection reconciliation keys distinct from the public Field identity.
final class _CatchSectionRowKey extends ValueKey<Object> {
  const _CatchSectionRowKey(super.value);
}

/// Internal renderer for the typed Field collection recipes on CatchSection.
///
/// The box occupies the interaction plane. Gutters constrain its content, never
/// its hit target. Lazy mode preserves the same geometry without eager widgets.
class CatchSectionRows extends StatefulWidget {
  const CatchSectionRows({
    super.key,
    required List<CatchField> this.entries,
    this.title,
    this.count,
    this.action,
    this.contained = false,
  }) : _itemCount = null,
       formLeadingInset = null,
       itemBuilder = null,
       findChildIndexCallback = null;

  const CatchSectionRows.sliver({
    super.key,
    required int this._itemCount,
    required this.itemBuilder,
    this.findChildIndexCallback,
    this.title,
    this.count,
    this.action,
  }) : entries = null,
       formLeadingInset = null,
       contained = false;

  /// Package-owned form coordinators retain draft/save state around a Field.
  /// Every descriptor carries the canonical icon lane; product code cannot
  /// supply a widget builder to the public row-section recipes.
  const CatchSectionRows.form({
    super.key,
    required List<Widget> this.entries,
    required double leadingInset,
    this.title,
    this.count,
    this.action,
  }) : formLeadingInset = leadingInset,
       _itemCount = null,
       itemBuilder = null,
       findChildIndexCallback = null,
       contained = false;

  final List<Widget>? entries;
  final double? formLeadingInset;

  final int? _itemCount;
  int get itemCount => entries?.length ?? _itemCount!;
  final CatchField Function(BuildContext, int)? itemBuilder;
  final int? Function(Key)? findChildIndexCallback;
  final String? title;
  final Object? count;
  final Widget? action;
  final bool contained;

  @override
  State<CatchSectionRows> createState() => _CatchSectionRowsState();
}

class _CatchSectionRowsState extends State<CatchSectionRows> {
  final Set<Object> _active = {};
  final Map<int, Object> _identities = {};

  @override
  void didUpdateWidget(CatchSectionRows oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries case final entries?) {
      final identities = {
        for (var i = 0; i < entries.length; i++) entries[i].key ?? i,
      };
      _active.retainAll(identities);
    }
    _identities.clear();
  }

  Widget? _header(double gutter) {
    if (widget.title == null && widget.count == null && widget.action == null) {
      return null;
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
      child: CatchSectionHeading(
        title: widget.title,
        count: widget.count,
        action: widget.action,
      ),
    );
  }

  bool _isActive(int index) {
    if (index >= widget.itemCount) return false;
    final entries = widget.entries;
    if (entries != null &&
        entries[index] is CatchField &&
        (entries[index] as CatchField).states.contains(WidgetState.selected)) {
      return true;
    }
    final identity = entries != null
        ? entries[index].key ?? index
        : _identities[index];
    return identity != null && _active.contains(identity);
  }

  Widget _row(
    BuildContext context,
    int index,
    double gutter, {
    bool fullPlane = true,
  }) {
    final entry = widget.entries?[index] ?? widget.itemBuilder!(context, index);
    final identity = entry.key ?? index;
    _identities[index] = identity;
    return KeyedSubtree(
      key: _CatchSectionRowKey(identity),
      child: NotificationListener<CatchFieldActivityNotification>(
        onNotification: (notification) {
          if (notification.active == _active.contains(identity)) return true;
          setState(() {
            if (notification.active) {
              _active.add(identity);
            } else {
              _active.remove(identity);
            }
          });
          return true;
        },
        child: Stack(
          children: [
            CatchFieldGeometryScope(
              gutterOwnership: CatchFieldGeometryScopeMode.field,
              contentInsets: EdgeInsets.symmetric(horizontal: gutter),
              interactionOutsets: EdgeInsets.zero,
              exactBounds: true,
              interactionShape: widget.contained
                  ? CatchFieldGeometryScopeVariant.sectionClipped
                  : fullPlane
                  ? CatchFieldGeometryScopeVariant.fullBleedBand
                  : CatchFieldGeometryScopeVariant.roundedTile,
              child: entry,
            ),
            if (index < widget.itemCount - 1)
              PositionedDirectional(
                start:
                    gutter +
                    (widget.formLeadingInset ??
                        (entry as CatchField).fieldDividerLeadingInset),
                end: gutter,
                bottom: 0,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _isActive(index) || _isActive(index + 1) ? 0 : 1,
                    duration: catchFieldMotionDuration(
                      context,
                      CatchFieldTokens.standard,
                    ),
                    child: const CatchDivider.fieldRow(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries == null) {
      return SliverLayoutBuilder(
        builder: (context, constraints) {
          assert(
            CatchRowViewport.matches(context, constraints.crossAxisExtent),
            'A row section must fill its page or pane. Remove outer padding; use containedRows for an inset surface.',
          );
          final gutter = catchSectionContentGutter(constraints.crossAxisExtent);
          final header = _header(gutter);
          return SliverMainAxisGroup(
            slivers: [
              if (header != null) SliverToBoxAdapter(child: header),
              SliverList.builder(
                itemCount: widget.itemCount,
                findChildIndexCallback: widget.findChildIndexCallback == null
                    ? null
                    : (key) => key is _CatchSectionRowKey && key.value is Key
                          ? widget.findChildIndexCallback!(key.value as Key)
                          : null,
                itemBuilder: (context, index) => _row(
                  context,
                  index,
                  gutter,
                  fullPlane: CatchRowViewport.matches(
                    context,
                    constraints.crossAxisExtent,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        assert(
          constraints.hasBoundedWidth,
          'Row sections need a page or pane.',
        );
        assert(
          widget.contained ||
              CatchRowViewport.matches(context, constraints.maxWidth),
          'A row section must fill its page or pane. Remove outer padding; use containedRows for an inset surface.',
        );
        final gutter = catchSectionContentGutter(constraints.maxWidth);
        final header = _header(gutter);
        final rows = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < widget.itemCount; i++)
              _row(
                context,
                i,
                widget.contained
                    ? CatchFieldTokens.rowHorizontalPadding
                    : gutter,
                fullPlane: CatchRowViewport.matches(
                  context,
                  constraints.maxWidth,
                ),
              ),
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ?header,
            if (widget.contained)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: gutter),
                child: CatchSectionSurface.fieldRows(
                  padding: EdgeInsets.zero,
                  child: rows,
                ),
              )
            else
              rows,
          ],
        );
      },
    );
  }
}
