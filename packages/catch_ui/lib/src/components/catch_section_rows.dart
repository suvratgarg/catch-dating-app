import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field.dart';
import 'package:catch_ui/src/components/catch_field_activity_notification.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope_mode.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope_variant.dart';
import 'package:catch_ui/src/components/catch_field_motion.dart';
import 'package:catch_ui/src/components/catch_section_header.dart';
import 'package:catch_ui/src/components/catch_section_surface.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
import 'package:catch_ui/src/primitives/catch_kicker_text.dart';
import 'package:flutter/material.dart';

/// Internal renderer for the typed Field collection recipes on CatchSection.
///
/// The box occupies the interaction plane. Gutters constrain its content, never
/// its hit target. Lazy mode preserves the same geometry without eager widgets.
class CatchSectionRows extends StatefulWidget {
  const CatchSectionRows({
    super.key,
    required List<CatchField> entries,
    this.title,
    this.count,
    this.action,
    this.contained = false,
  }) : entries = entries,
       _itemCount = null,
       itemBuilder = null,
       findChildIndexCallback = null;

  const CatchSectionRows.sliver({
    super.key,
    required int itemCount,
    required this.itemBuilder,
    this.findChildIndexCallback,
    this.title,
    this.count,
    this.action,
  }) : _itemCount = itemCount,
       entries = null,
       contained = false;

  final List<CatchField>? entries;
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

  double _gutter(double width) => math.max(
    CatchSpacing.screenPx,
    (width - CatchLayout.maxContentWidth) / 2,
  );

  Widget? _header(double gutter) {
    if (widget.title == null && widget.count == null && widget.action == null) {
      return null;
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchSectionHeader.kicker(
            title: widget.title,
            count: widget.count,
            trailing: widget.action,
            color: CatchTokens.of(context).ink2,
            textVariant: CatchKickerTextVariant.fieldSection,
          ),
          const SizedBox(height: CatchFieldTokens.sectionRuleGap),
          const CatchDivider.section(),
        ],
      ),
    );
  }

  bool _isActive(int index) {
    if (index >= widget.itemCount) return false;
    final entries = widget.entries;
    if (entries != null &&
        entries[index].states.contains(WidgetState.selected)) {
      return true;
    }
    final identity = entries != null
        ? entries[index].key ?? index
        : _identities[index];
    return identity != null && _active.contains(identity);
  }

  Widget _row(BuildContext context, int index, double gutter) {
    final entry = widget.entries?[index] ?? widget.itemBuilder!(context, index);
    final identity = entry.key ?? index;
    _identities[index] = identity;
    return KeyedSubtree(
      key: entry.key ?? ValueKey(index),
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
                  : CatchFieldGeometryScopeVariant.fullBleedBand,
              child: entry,
            ),
            if (index < widget.itemCount - 1)
              PositionedDirectional(
                start: gutter + entry.fieldDividerLeadingInset,
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
          final gutter = _gutter(constraints.crossAxisExtent);
          final header = _header(gutter);
          return SliverMainAxisGroup(
            slivers: [
              if (header != null) SliverToBoxAdapter(child: header),
              SliverList.builder(
                itemCount: widget.itemCount,
                findChildIndexCallback: widget.findChildIndexCallback,
                itemBuilder: (context, index) => _row(context, index, gutter),
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
        final gutter = _gutter(constraints.maxWidth);
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
              ),
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) header,
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
