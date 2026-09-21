import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/contract_preview.dart';

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchRootScreenScaffold,
  path: '[Core primitives]/Navigation',
)
Widget catchRootScreenPrimaryRailContractStates(BuildContext context) {
  return const _RootScreenContractUseCase();
}

@widgetbook.UseCase(
  name: 'Root page with primary rail',
  type: CatchRootScreenPageScrollView,
  path: '[Core primitives]/Navigation',
)
Widget catchRootScreenPageContractStates(BuildContext context) {
  return const _RootScreenContractUseCase();
}

@widgetbook.UseCase(
  name: 'Readable sliver width',
  type: CatchViewport,
  path: '[Core primitives]/Navigation',
)
Widget catchViewportSliverLaneContractStates(BuildContext context) {
  return const _RootScreenContractUseCase();
}

@widgetbook.UseCase(
  name: 'Controller-backed rail',
  type: CatchPageTabBar,
  path: '[Core primitives]/Navigation',
)
Widget catchPageTabBarControllerStates(BuildContext context) {
  return const _RootScreenContractUseCase();
}

class _RootScreenContractUseCase extends StatelessWidget {
  const _RootScreenContractUseCase();

  @override
  Widget build(BuildContext context) {
    return const WidgetbookContractFrame(
      title: 'CatchRootScreenScaffold',
      contractId: 'catch.screen_body.root_screen_scaffold',
      states: [
        'standard',
        'full-bleed',
        'primary-rail',
        'paged-primary-rail',
        'responsive-width',
        'floating-bottom-navigation',
        'side-navigation',
      ],
      children: [
        WidgetbookContractStateCard(
          label: 'shared shell',
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: _RootScreenPrimaryRailContractDemo(),
          ),
        ),
      ],
    );
  }
}

class _RootScreenPrimaryRailContractDemo extends StatefulWidget {
  const _RootScreenPrimaryRailContractDemo();

  @override
  State<_RootScreenPrimaryRailContractDemo> createState() =>
      _RootScreenPrimaryRailContractDemoState();
}

class _RootScreenPrimaryRailContractDemoState
    extends State<_RootScreenPrimaryRailContractDemo>
    with SingleTickerProviderStateMixin {
  late final TabController _controller = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchRootScreenScaffold.withPrimaryRail(
      header: const CatchRootScreenHeader.title(
        title: 'Root workspace',
        subtitle: 'Independent page scroll state',
      ),
      semanticsLabel: 'Root primary-rail contract preview',
      actions: CatchPageTabBar<String>.controlled(
        controller: _controller,
        options: const [
          CatchOption(value: 'edit', label: 'Edit'),
          CatchOption(value: 'preview', label: 'Preview'),
        ],
      ),
      body: CatchRootScreenBody.paged(
        controller: _controller,
        pages: const [
          CatchRootScreenPageSpec.scroll(
            page: CatchRootScreenPageScrollView.standard(
              scrollKey: PageStorageKey<String>('contract-tab-edit'),
              children: [
                SliverToBoxAdapter(
                  child: Text('Edit owns this scroll position.'),
                ),
              ],
            ),
          ),
          CatchRootScreenPageSpec.scroll(
            page: CatchRootScreenPageScrollView.standard(
              scrollKey: PageStorageKey<String>('contract-tab-preview'),
              children: [
                SliverToBoxAdapter(
                  child: Text('Preview owns a separate scroll position.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
