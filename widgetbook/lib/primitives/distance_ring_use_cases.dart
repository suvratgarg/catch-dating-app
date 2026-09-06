import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Fixed diameter and edge label',
  type: CatchDistanceRingViewport,
  path: '[Core primitives]/Activity',
)
Widget distanceRingViewportStates(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'Distance ring viewport',
      catalogId: 'catch.distance_ring.viewport',
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            const CatchDistanceRingViewport(
              size: 128,
              label: null,
              semanticLabel: null,
              semanticHint: null,
              onTap: null,
            ),
            CatchDistanceRingViewport(
              size: 180,
              label: '2 km',
              semanticLabel: 'Two kilometers',
              semanticHint: 'Choose range',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
