import 'package:flutter/widgets.dart';

/// Marker for an analyzer-verified semantic root-screen page owner.
///
/// Canonical pages use `CatchRootScreenPageScrollView` directly. Feature owners
/// may implement this interface only when their build terminal delegates to
/// that scroll owner; the resolved composition checker enforces that boundary.
abstract interface class CatchRootScreenPageOwner implements Widget {}
