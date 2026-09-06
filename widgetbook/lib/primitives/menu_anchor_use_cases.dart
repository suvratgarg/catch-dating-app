import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Top anchored menu',
  type: CatchMenuAnchor,
  path: '[Core primitives]/Menus',
)
Widget catchMenuAnchorTop(BuildContext context) =>
    const WidgetbookMenuAnchorCanvas(alignment: Alignment.topCenter);

@widgetbook.UseCase(
  name: 'Bottom anchored menu',
  type: CatchMenuAnchor,
  path: '[Core primitives]/Menus',
)
Widget catchMenuAnchorBottom(BuildContext context) =>
    const WidgetbookMenuAnchorCanvas(alignment: Alignment.bottomCenter);

/// Bounded canvas for the real menu's overlay placement and scrolling.
class WidgetbookMenuAnchorCanvas extends StatelessWidget {
  const WidgetbookMenuAnchorCanvas({super.key, required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return WidgetbookCatalogFrame(
      title: 'CatchMenuAnchor',
      catalogId: 'catch.menu.anchor',
      children: [
        SizedBox(
          height: 720,
          child: CatchTabViewportScope(
            index: 0,
            bottomOverlayInset: 100,
            bottomBarPlacement: CatchTabViewportScopePlacement.floating,
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 140),
              child: Align(
                alignment: alignment,
                child: SizedBox(
                  width: 320,
                  child: WidgetbookOpenMenuScope(
                    builder: (context, controller) => CatchMenuAnchor<int>(
                      controller: controller,
                      items: [
                        for (var index = 0; index < 20; index++)
                          CatchMenuItem(
                            value: index,
                            label: 'Option ${index + 1}',
                            selected: index == 0,
                            role: CatchMenuItemRole.choice,
                          ),
                      ],
                      onSelected: (_, _) => controller.close(),
                      builder: (context, controller, child) => CatchTextButton(
                        label: 'Open menu',
                        onPressed: controller.open,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
