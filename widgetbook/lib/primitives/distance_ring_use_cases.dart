import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Fixed diameter and edge label',
  type: CatchDistanceOverlay,
  path: '[Core primitives]/Activity',
)
Widget distanceOverlayGeometryStates(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'Distance overlay geometry',
      catalogId: 'catch.distance_ring',
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            const CatchDistanceOverlay(
              size: 128,
              label: null,
              semanticLabel: null,
              semanticHint: null,
              onTap: null,
            ),
            CatchDistanceOverlay(
              size: 180,
              label: '2 km',
              semanticLabel: 'Two kilometers',
              semanticHint: 'Choose range',
              onTap: () {},
            ),
            const SizedBox.square(
              dimension: CatchLayout.distanceRingDefaultSize,
              child: Center(
                child: CatchDistanceOverlay(
                  fitAvailable: true,
                  label: 'Fitted radius',
                ),
              ),
            ),
          ],
        ),
      ],
    );
