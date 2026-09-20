import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final placement in [null, ...CatchTabViewportScopePlacement.values]) {
    testWidgets('terminal clearance preserves $placement ownership', (
      tester,
    ) async {
      double? terminal;
      double? overlay;
      double? clearance;
      int? activeIndex;
      final reader = Builder(
        builder: (context) {
          terminal = CatchTabViewportScope.scrollTerminalClearanceOf(
            context,
            extra: 7,
          );
          overlay = CatchTabViewportScope.bottomOverlayInsetOf(context);
          clearance = CatchTabViewportScope.bottomOverlayClearanceOf(
            context,
            minimum: 5,
          );
          activeIndex = CatchTabViewportScope.maybeIndexOf(context);
          return const SizedBox();
        },
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: 16),
              viewPadding: EdgeInsets.only(bottom: 32),
            ),
            child: placement == null
                ? reader
                : CatchTabViewportScope(
                    index: 2,
                    bottomBarPlacement: placement,
                    bottomOverlayInset:
                        placement == CatchTabViewportScopePlacement.floating
                        ? 88
                        : 0,
                    child: reader,
                  ),
          ),
        ),
      );
      final floats = placement == CatchTabViewportScopePlacement.floating;
      expect(terminal, switch (placement) {
        CatchTabViewportScopePlacement.floating => 95,
        CatchTabViewportScopePlacement.anchored => 7,
        _ => 39,
      });
      expect(overlay, floats ? 88 : 0);
      expect(clearance, floats ? 77 : 5);
      expect(activeIndex, placement == null ? null : 2);
    });
  }

  testWidgets('viewport consumes updated obstruction and supports opt-out', (
    tester,
  ) async {
    Future<void> pump(double inset, {bool account = true}) => tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CatchTabViewportScope(
          index: 0,
          bottomBarPlacement: CatchTabViewportScopePlacement.floating,
          bottomOverlayInset: inset,
          child: CatchStateViewport(
            accountForBottomOverlay: account,
            child: const SizedBox(),
          ),
        ),
      ),
    );
    await pump(40);
    expect(
      tester.widget<Padding>(find.byType(Padding)).padding,
      const EdgeInsets.only(bottom: 40),
    );
    await pump(72);
    expect(
      tester.widget<Padding>(find.byType(Padding)).padding,
      const EdgeInsets.only(bottom: 72),
    );
    await pump(72, account: false);
    expect(
      tester.widget<Padding>(find.byType(Padding)).padding,
      EdgeInsets.zero,
    );
  });

  testWidgets('loading centers in the unobstructed bounded body', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 600,
          child: CatchTabViewportScope(
            index: 0,
            bottomBarPlacement: CatchTabViewportScopePlacement.floating,
            bottomOverlayInset: 80,
            child: const CatchStateViewport.loading(),
          ),
        ),
      ),
    );

    final viewport = tester.getRect(find.byType(CatchStateViewport));
    final progress = tester.getCenter(find.byType(CircularProgressIndicator));
    expect(progress.dy, closeTo(viewport.top + (viewport.height - 80) / 2, 1));
  });

  testWidgets('sliver loading centers below persistent content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CatchTabViewportScope(
          index: 0,
          bottomBarPlacement: CatchTabViewportScopePlacement.floating,
          bottomOverlayInset: 80,
          child: CustomScrollView(
            slivers: const [
              SliverToBoxAdapter(child: SizedBox(height: 100)),
              CatchStateViewport.sliverLoading(),
            ],
          ),
        ),
      ),
    );

    final viewport = tester.getRect(find.byType(CustomScrollView));
    final progress = tester.getCenter(find.byType(CircularProgressIndicator));
    expect(
      progress.dy,
      closeTo(viewport.top + 100 + (viewport.height - 100 - 80) / 2, 1),
    );
  });
}
