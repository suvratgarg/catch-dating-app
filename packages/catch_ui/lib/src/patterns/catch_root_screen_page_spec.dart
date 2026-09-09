// ignore_for_file: prefer_initializing_formals

import 'package:catch_ui/src/patterns/catch_master_detail_viewport.dart';
import 'package:catch_ui/src/patterns/catch_root_screen_page_owner.dart';
import 'package:flutter/widgets.dart';

enum _CatchRootScreenPageKind { scroll, surface, masterDetail }

/// Typed page entry accepted by `CatchRootScreenBody`.
///
/// Every variant retains `CatchRootScreenPageScrollView` as the page's scroll and
/// geometry owner. Surface decoration and expanded master-detail composition
/// remain explicit adapters rather than arbitrary page children.
final class CatchRootScreenPageSpec {
  const CatchRootScreenPageSpec.scroll({required CatchRootScreenPageOwner page})
    : _kind = _CatchRootScreenPageKind.scroll,
      _page = page,
      _backgroundColor = null,
      _expanded = false,
      _detail = null;

  const CatchRootScreenPageSpec.surface({
    required CatchRootScreenPageOwner page,
    required Color backgroundColor,
  }) : _kind = _CatchRootScreenPageKind.surface,
       _page = page,
       _backgroundColor = backgroundColor,
       _expanded = false,
       _detail = null;

  const CatchRootScreenPageSpec.masterDetail({
    required bool expanded,
    required CatchRootScreenPageOwner master,
    required Widget detail,
  }) : _kind = _CatchRootScreenPageKind.masterDetail,
       _page = master,
       _backgroundColor = null,
       _expanded = expanded,
       _detail = detail;

  final _CatchRootScreenPageKind _kind;
  final CatchRootScreenPageOwner _page;
  final Color? _backgroundColor;
  final bool _expanded;
  final Widget? _detail;

  Widget build() {
    return switch (_kind) {
      _CatchRootScreenPageKind.scroll => _page as Widget,
      _CatchRootScreenPageKind.surface => ColoredBox(
        color: _backgroundColor!,
        child: _page as Widget,
      ),
      _CatchRootScreenPageKind.masterDetail => CatchMasterDetailViewport(
        expanded: _expanded,
        leading: _page as Widget,
        body: _detail!,
      ),
    };
  }
}
