import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Standard and full-bleed route bodies',
  type: CatchRouteScaffold,
  path: '[Core patterns]/Page protocols',
)
Widget routeBodyRoleStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Route body roles',
  catalogId: 'catch.screen_body.route_scaffold',
  children: [
    for (final fullBleed in [false, true])
      WidgetbookViewportFrame.device(
        size: const Size(360, 300),
        child: Builder(
          builder: (context) => CatchRouteScaffold(
            topBarBuilder: (context, scrolledUnder) => CatchTopBar(
              title: fullBleed ? 'Edge-owned route' : 'Standard route',
              leadingType: CatchTopBarLeading.none,
              divider: scrolledUnder,
            ),
            body: fullBleed
                ? CatchRouteBody.fullBleed(
                    child: ColoredBox(
                      color: CatchTokens.of(context).primarySoft,
                      child: Center(
                        child: Text(
                          'Edge-owned viewport',
                          style: CatchTextStyles.bodyM(context),
                        ),
                      ),
                    ),
                  )
                : CatchRouteBody.standard(
                    child: Text(
                      'The route owns the page gutter and scroll clearance.',
                      style: CatchTextStyles.bodyM(context),
                    ),
                  ),
          ),
        ),
      ),
  ],
);

@widgetbook.UseCase(
  name: 'Typed pages and scroll-position controller',
  type: CatchRootScreenBody,
  path: '[Core patterns]/Page protocols',
)
Widget rootPageProtocolStates(BuildContext context) =>
    const WidgetbookCatalogFrame(
      title: 'Root page protocols',
      catalogId: 'catch.screen_body.root_screen_body',
      children: [
        WidgetbookViewportFrame.device(
          size: Size(360, 480),
          child: _RootPageProtocolPreview(),
        ),
      ],
    );

class _RootPageProtocolPreview extends StatefulWidget {
  const _RootPageProtocolPreview();

  @override
  State<_RootPageProtocolPreview> createState() =>
      _RootPageProtocolPreviewState();
}

class _RootPageProtocolPreviewState extends State<_RootPageProtocolPreview>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final _scroll = CatchRootScreenPageScrollController();
  double? _savedOffset;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CatchRootScreenPageOwner records =
        CatchRootScreenPageScrollView.standard(
          scrollKey: const PageStorageKey<String>('protocol-records'),
          scrollStateController: _scroll,
          slivers: [
            SliverList.builder(
              itemCount: 12,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s3),
                child: Text(
                  'Record ${index + 1}',
                  style: CatchTextStyles.bodyM(context),
                ),
              ),
            ),
          ],
        );
    final CatchPrimaryRail rail = CatchTabControllerRail<String>(
      controller: _tabs,
      options: const [
        CatchOption(value: 'records', label: 'Records'),
        CatchOption(value: 'detail', label: 'Detail'),
      ],
    );
    return CatchRootScreenScaffold.withPrimaryRail(
      header: CatchRootScreenHeader.title(
        title: 'Root page',
        actions: [
          CatchTopBarTextAction(
            label: 'Save',
            onPressed: () =>
                setState(() => _savedOffset = _scroll.captureOffset()),
          ),
          CatchTopBarTextAction(
            label: 'Restore',
            onPressed: _savedOffset == null
                ? null
                : () => _scroll.restoreOffset(_savedOffset),
          ),
        ],
      ),
      primaryRail: rail,
      body: CatchRootScreenBody.paged(
        controller: _tabs,
        pages: [
          CatchRootScreenPageSpec.surface(
            page: records,
            backgroundColor: CatchTokens.of(context).bg,
          ),
          CatchRootScreenPageSpec.masterDetail(
            expanded: false,
            master: CatchRootScreenPageScrollView.fullBleed(
              scrollKey: const PageStorageKey<String>('protocol-detail'),
              slivers: [
                SliverToBoxAdapter(
                  child: Text(
                    'Full-bleed page',
                    style: CatchTextStyles.bodyM(context),
                  ),
                ),
              ],
            ),
            detail: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
