// ignore_for_file: prefer_initializing_formals

import 'package:catch_ui/src/patterns/catch_root_screen_page_owner.dart';
import 'package:flutter/widgets.dart';

enum _CatchRootScreenPageKind { scroll, surface }

/// Typed page entry accepted by `CatchRootScreenBody`.
///
/// Every variant retains `CatchRootScreenPageScrollView` as the page's scroll and
/// geometry owner. Surface decoration remains an explicit adapter; navigation paths belong to
/// CatchNavigationViewport outside individual pages.
final class CatchRootScreenPageSpec {
  const CatchRootScreenPageSpec.scroll({required CatchRootScreenPageOwner page})
    : _kind = _CatchRootScreenPageKind.scroll,
      _page = page,
      _backgroundColor = null;

  const CatchRootScreenPageSpec.surface({
    required CatchRootScreenPageOwner page,
    required Color backgroundColor,
  }) : _kind = _CatchRootScreenPageKind.surface,
       _page = page,
       _backgroundColor = backgroundColor;

  final _CatchRootScreenPageKind _kind;
  final CatchRootScreenPageOwner _page;
  final Color? _backgroundColor;

  Widget build() {
    return switch (_kind) {
      _CatchRootScreenPageKind.scroll => _page as Widget,
      _CatchRootScreenPageKind.surface => ColoredBox(
        color: _backgroundColor!,
        child: _page as Widget,
      ),
    };
  }
}
