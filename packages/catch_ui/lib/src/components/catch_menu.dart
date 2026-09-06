import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_menu_item.dart';
import 'package:catch_ui/src/components/catch_menu_row.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

/// Handoff `Menu`: anchored surface panel of selectable rows.
class CatchMenu<T> extends StatelessWidget {
  const CatchMenu({
    super.key,
    required this.items,
    this.onSelected,
    this.width,
  });

  final List<CatchMenuItem<T>> items;
  final void Function(T value, CatchMenuItem<T> item)? onSelected;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewportHeight = math.max(
      0.0,
      mediaQuery.size.height - mediaQuery.padding.vertical,
    );
    final maxHeight = CatchLayout.menuMaxHeightFor(viewportHeight);

    return CatchSurface(
      elevation: CatchSurfaceElevation.overlay,
      radius: CatchRadius.md,
      borderRole: CatchBorderRole.boundary,
      padding: EdgeInsets.zero,
      width: width,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final indexed in items.indexed) ...[
                if (indexed.$1 > 0 && indexed.$2.startsSection)
                  const CatchDivider.fieldRow(indent: 0),
                CatchMenuRow<T>(item: indexed.$2, onSelected: onSelected),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
