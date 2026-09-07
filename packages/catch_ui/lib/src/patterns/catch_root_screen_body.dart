// ignore_for_file: prefer_initializing_formals

import 'package:catch_ui/src/patterns/catch_root_screen_page_spec.dart';
import 'package:flutter/material.dart';

enum _CatchRootScreenBodyKind { single, paged }

/// Closed body specification for `CatchRootScreenScaffold`.
///
/// This prevents a feature from supplying a raw `TabBarView` or unrelated
/// widget. Every visible page is a typed [CatchRootScreenPageSpec] whose primary
/// scroll owner is `CatchRootScreenPageScrollView`.
final class CatchRootScreenBody {
  const CatchRootScreenBody.single({required CatchRootScreenPageSpec page})
    : _kind = _CatchRootScreenBodyKind.single,
      _page = page,
      _pages = null,
      _controller = null,
      _physics = null;

  const CatchRootScreenBody.paged({
    required TabController controller,
    required List<CatchRootScreenPageSpec> pages,
    ScrollPhysics? physics,
  }) : _kind = _CatchRootScreenBodyKind.paged,
       _page = null,
       _pages = pages,
       _controller = controller,
       _physics = physics;

  final _CatchRootScreenBodyKind _kind;
  final CatchRootScreenPageSpec? _page;
  final List<CatchRootScreenPageSpec>? _pages;
  final TabController? _controller;
  final ScrollPhysics? _physics;

  Widget build() {
    assert(
      _kind != _CatchRootScreenBodyKind.paged || _pages!.isNotEmpty,
      'CatchRootScreenBody.paged requires at least one page.',
    );
    return switch (_kind) {
      _CatchRootScreenBodyKind.single => _page!.build(),
      _CatchRootScreenBodyKind.paged => TabBarView(
        controller: _controller,
        physics: _physics,
        children: [for (final page in _pages!) page.build()],
      ),
    };
  }
}
